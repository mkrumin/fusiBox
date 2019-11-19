function getAnimalSummary(animalName)

fusSummary = getAllFusiExps(animalName);

nStacks = length(fusSummary);

% Load all the stacks and interactively set the brain boundaries
for iStack = 1:nStacks
    ys(iStack) = YStack(fusSummary(iStack).stackRef);
    h = ys(iStack).manualCrop;
    close(h);
end

% for each stack, plot the slices where fUSi was performed
for iStack = 1:nStacks
    yPos = [];
    for iFus = 1:length(fusSummary(iStack).fusRef)
        folderName = dat.expPath(fusSummary(iStack).fusRef{iFus}, 'main', 'master');
        fusFilename = fullfile(folderName, [fusSummary(iStack).fusRef{iFus}, '_fus.mat']);
        data = load(fusFilename);
        yPos(iFus) = data.doppler.motorPosition;
    end
    [isIn, sliceIdx] = ismember(round(yPos, 2), round(ys(iStack).yAxis, 2));
    ys(iStack).plotSlices(unique(sliceIdx(isIn)));
end
