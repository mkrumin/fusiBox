function out = acqLoop(src, event)

global SCAN
persistent nFramesAcc data

frameRate = 10; % [Hz] Currently this is the frame rate
singleRunDuration = 5; % [sec]
nFramesPerRun = round(singleRunDuration * frameRate);
maxFrames = round(3600*frameRate);

if SCAN.flagRun
    tic
    SCAN.FilmFast(nFramesPerRun);
    toc
    if isempty(nFramesAcc)
        % initialize variables on the first run
        nFramesAcc = 0;
        [nZ, nX] = size(SCAN.I0);
        % preallocate an empty array
        data = zeros(nZ, nX, maxFrames, class(SCAN.I1));
    end
    dataBatch = SCAN.I1;
    nFramesBatch = size(dataBatch, 3);
    frameIdx = nFramesAcc + [1:nFramesBatch];
    if max(frameIdx)>size(data, 3)
        % increase preallocated array size
        fprintf('\nPreallocating more space...\n');
        data = cat(3, data, zeros(nZ, nX, maxFrames, class(SCAN.I1)));
    end
    fprintf('\nSaving to the array...\n');
    tic
    data(:,:,frameIdx) = dataBatch;
    nFramesAcc = nFramesAcc + nFramesBatch;
    toc
    fprintf('Now %d frames long\n', nFramesAcc)
    out = [];
else
    fprintf('flagRUN is false, returning the acquired data\n');
    out = data(:, :, 1:nFramesAcc);
    % persistent variables should be cleared outside the function by
    % calling 'clear acqLoop'
end
