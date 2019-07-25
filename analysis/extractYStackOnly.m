folder = 'F:\fUSiData';
animalName = 'PC036';
animalFolder = fullfile(folder, animalName)

files = dir([animalFolder, '\*_YSMask.mat']);
%%

nFiles = length(files);
for iFile = 1:nFiles
    fprintf('%g/%g\n', iFile, nFiles)
    load(fullfile(animalFolder, files(iFile).name));
    ys.ExpRef = YSLite.ExpRef;
    ys.YStack = YSLite.Doppler;
    ys.xAxis = YSLite.xAxis;
    ys.zAxis = YSLite.zAxis;
    ys.yAxis = YSLite.yAxis;
    save(fullfile(animalFolder, strrep(files(iFile).name, 'YSMask', 'YSOnly')))
end
