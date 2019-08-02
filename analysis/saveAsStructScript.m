% save as struct script

dataFolder = 'F:\fUSiData\PC041';

files = dir(fullfile(dataFolder, '*_YS.mat'));

nFiles = length(files);

for iFile = 1:nFiles
    tStart = tic;
    fprintf('Processing file %g/%g (%3.1f GB)..', iFile, nFiles, files(iFile).bytes/1024^3);
    file2load = fullfile(dataFolder, files(iFile).name);
    fileName2Save = strrep(file2load, '_YS.mat', '_YSStruct.mat');
    load(file2load);
    YS.exportStruct(fileName2Save);
    fprintf('.done (%3.1f seconds)\n', toc(tStart));
end