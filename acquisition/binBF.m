function binBF(ExpRef)

% figuring out where to load the data from and where to save the results
p = dat.paths;
[folderName, fileStem] = dat.expPath(ExpRef, 'main', 'local');
fileName = sprintf('%s_fus.mat', fileStem);
fullFileName = fullfile(folderName, fileName);

% loading the data without the fast binned BF data
data = load(fullFileName);
doppler = data.doppler;
clear data;
nFrames = size(doppler.frames, 3);
folderFullData = doppler.params.folderFullData;

% binning the fast BF data
tic
fullDataFolderName = strrep(folderName, p.localRepository, folderFullData);
if exist(fullDataFolderName, 'dir')
    fprintf('Binning BFFilt data for %s:\n', ExpRef);
    files = dir(fullfile(fullDataFolderName, [fileStem, '_BFfilt_*.mat']));
    fastFrames = cell(nFrames, 1);
    binSize = 30;
    nChars = 0;
    for iFile = 1:length(files)
        if mod(iFile, 10) == 1
            fprintf(repmat('\b', 1, nChars));
            nChars = fprintf('Frame %g/%g', iFile, length(files));
        end
        iFrame = sscanf(files(iFile).name, [fileStem, '_BFfilt_%u.mat']);
        tmp = load(fullfile(fullDataFolderName, files(iFile).name));
        dat2 = abs(tmp.BFFilt).^2;
        [~, nZ, nX] = size(dat2);
        fastFrames{iFrame} = ...
            squeeze(mean(reshape(permute(dat2, [2 3 1]), nZ, nX, binSize, []), 3));
    end
    fprintf('\n');
    doppler.fastFrames = fastFrames;
    doppler.dtFastFrames = doppler.dtBF * binSize;
end
toc

% saving
tic;
fprintf('Saving the data to %s ..', fullFileName);
save(fullFileName, 'doppler', '-v7.3')
fprintf('.done (%3.1f seconds)\n', toc);

