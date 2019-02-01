function saveDopplerMovie(obj, frames)

nFrames = obj.fusIndex;

folderName = obj.fus;
fileName = sprintf('%s_fus.mat', obj.experimentName);

fullFileName = fullfile(folderName, fileName);
% I = obj.I1;

if nargin>1
    doppler.frames = frames;
    % for fast doppler we have no software timing data
    doppler.softTimes = [];
else
    doppler.frames = obj.I1(:,:,1:nFrames);
    doppler.softTimes = obj.time(1:nFrames);
end
[xAxis, zAxis, dt] = obj.getAxis;
doppler.xAxis = xAxis;
doppler.zAxis = zAxis;
doppler.motorPosition = obj.HARD.motorPosition;
doppler.nBFPerFrame = size(obj.BFfilt, 1);
doppler.dtBF = dt(1);
doppler.dtSinglePlanewave = dt(2);
doppler.dtRF = dt(3);
doppler.params = getParameters(obj);

%%
tic
p = dat.paths;
fullDataFolderName = strrep(folderName, p.localRepository, obj.folderFullData);
if exist(fullDataFolderName, 'dir')
    fprintf('Binning BFFilt data:\n');
    files = dir(fullfile(fullDataFolderName, [obj.experimentName, '_BFfilt_*.mat']));
    fastFrames = cell(nFrames, 1);
    binSize = 30;
    nChars = 0;
    for iFile = 1:length(files)
        fprintf(repmat('\b', 1, nChars));
        nChars = fprintf('Frame %g/%g', iFile, length(files));
        iFrame = sscanf(files(iFile).name, [obj.experimentName, '_BFfilt_%u.mat']);
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
%%
save(fullFileName, 'doppler', '-v6')
