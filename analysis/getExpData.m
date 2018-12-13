function out = getExpData(ExpRef)

p = getMpepProtocol(ExpRef);

hwInfo = getHardwareInfo(ExpRef);

stim = getStimTextures(hwInfo, p.pars, p.xfile);
% converting from cell array to a 3D matrix
% stimTextures = cell2mat(reshape(stim{1}.stimTextures(stim{1}.textureSequence), 1, 1, length(stim{1}.textureSequence)));
Timeline = getTimeline(ExpRef);
[stimTimes, frameTimes] = getStimTimes(Timeline, p);

doppler = getDoppler(ExpRef);

nBFPerFrame = doppler.params.sizeBF(3);
bfRate = 1/doppler.dtBF;
fusiFrameDuration = doppler.dtBF * nBFPerFrame;

% these are the frame onsets
fusiFrameOnsets = getFrameTimes(Timeline);
% and these will be the 'middles' of the frames
fusiFrameTimes = fusiFrameOnsets + nBFPerFrame/2/bfRate;
% and this will be the short time axis of the BF frames within a single
% Power Doppler frame
timesBF = doppler.dtBF * [0:nBFPerFrame-1];

% the last two frames acquired by the Verasonics are not
% getting processes and are not making it into the final data
fusiFrameTimes = fusiFrameTimes(1:end-2);
fusiFrameOnsets = fusiFrameOnsets(1:end-2);
% Timeline might miss the first few frames
% Also, the first frame of the movie is acquired before the experiment
% starts, the way acquisition currently works
nFramesAcquired = length(fusiFrameTimes);

nSkipFrames = length(doppler.softTimes) - nFramesAcquired;
doppler.frames = doppler.frames(:, :, nSkipFrames+1:end);
doppler.softTimes = doppler.softTimes(nSkipFrames+1:end);

try
eyeFilename = dat.expFilePath(ExpRef, 'eyetracking');
if exist([eyeFilename{1}, '.mj2'], 'file')
    eyeFilename = [eyeFilename{1}, '.mj2'];
else
    eyeFilename = [eyeFilename{2}, '.mj2'];
end
eyeMovie = VideoReader(eyeFilename);
catch e
    fprintf('There was a problem getting the eye-camera video: %s\n', e.message)
    eyeMovie = [];
end
try
    eyeTimes = et.getFrameTimes(ExpRef);
catch e
    fprintf('There was a problem getting the eye-camera timestamps: %s\n', e.message)
    eyeTimes = [];
end

out.p = p; % mpep Protocol
out.hwInfo = hwInfo; % hardware info for the stimulus monitors
out.stim = stim; % stimulus textures
out.TL = Timeline;
out.stimTimes = stimTimes; % onsets and offsent of the stimuli
out.stimFrameTimes = frameTimes; % timeStmps of the stimulus frames
out.doppler = doppler; % fUSi data
out.fusiFrameOnsets = fusiFrameOnsets; % onset timestamps of fUSi frames
out.fusiFrameDuration = fusiFrameDuration; % duration of eack fSUi frame
out.fusiFrameTimes = fusiFrameTimes; % timestamps of the 'middle' of the fUSi frames
out.eyeMovie = eyeMovie; % VideoReader object of the eye movie
out.eyeTimes = eyeTimes; % timestamps of the eye movie