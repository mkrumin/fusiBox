folderNames = {'Z:\fullDataSamples\CR017\2019-11-13\3'; ...
    'Z:\fullDataSamples\CR017\2019-11-14\2';...
    'Z:\fullDataSamples\CR020\2019-11-22\2'};
ExpRefs = {'2019-11-13_3_CR017'; '2019-11-14_2_CR017'; '2019-11-22_2_CR020'};
fs = 500; % [Hz]
frames2skip = 5;
binSizes = [1, 3, 5];
% maxNFrames = 100;

for iExp = 1:length(ExpRefs)
    ExpRef = ExpRefs{iExp};
    folderName = folderNames{iExp};
    fprintf('Processing, experiment %s\n', ExpRef');
    files = dir(fullfile(folderName, '*mat'));
    frames = frames2skip+1:length(files);
    frameTimes = getFrameTimes(getTimeline(ExpRef));
    for binSize = binSizes
        binStart = tic;
        fprintf('binSize = %g ms\n', binSize*100);
        nFrames = floor(length(frames)/binSize);
%         nFrames = min(nFrames, maxNFrames);
        startFrames = (0:nFrames-1) * binSize + 1;
        tAxis = frameTimes(startFrames);
        iFrame = 1;
        for ind = startFrames(iFrame) + [0:binSize-1]
            i = ind - startFrames(iFrame) + 1;
            data(i) = load(fullfile(files(frames(ind)).folder, files(frames(ind)).name));
        end
        bf = cell2mat(reshape({data(:).bf}, [], 1));
        [svdf, fAxis, lambdas] = svdfDecomposition(bf, fs);
        svdf = repmat(svdf, 1, 1, nFrames);
        svdf(:,:,2:end) = NaN;
        lambdas = repmat(lambdas, 1, 1, nFrames);
        for iFrame = 2:nFrames
            if ~mod(iFrame, 100)
                fprintf('Processing frame %g/%g\n', iFrame, nFrames);
            end
            for ind = startFrames(iFrame) + [0:binSize-1]
                i = ind - startFrames(iFrame) + 1;
                data(i) = load(fullfile(files(frames(ind)).folder, files(frames(ind)).name));
            end
            bf = cell2mat(reshape({data(:).bf}, [], 1));
            [svdf(:,:,iFrame), fAxis, lambdas(:, :, iFrame)] = svdfDecomposition(bf, fs);
        end
        fprintf('Done.\n');
        clear data;
        
        svdfNormalized = svdf;
        for iFrame = 1:nFrames
            svdf(:, :, iFrame) = svdfNormalized(:, :, iFrame) * diag(lambdas(:, 1, iFrame).^2);
        end
        fprintf('Processing done (for current bin size) in %1.0f seconds\n', toc(binStart));
        filename = fullfile('Z:\fullDataSamples\', ...
            sprintf('%s_binSize_%1.0f.mat', ExpRef, binSize));
        fprintf('Saving ..');
        save(filename, 'svdf', 'svdfNormalized', 'fAxis', 'lambdas', 'tAxis')
        fprintf('.done\n');
    end
end % iExp
