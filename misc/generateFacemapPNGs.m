rootFolder = 'Z:\FaceMapResults';

files = dir(fullfile(rootFolder, '*.mat'));

for iFile = 1:length(files)
    disp(iFile)
    res = load(fullfile(files(iFile).folder, files(iFile).name));
    targetPath = fullfile(rootFolder, [res.expDateStr, '_', res.animalName]);
    if ~exist(targetPath, 'dir')
        mkdir(targetPath)
    end
    plotFacemapResults(res, targetPath);
end

