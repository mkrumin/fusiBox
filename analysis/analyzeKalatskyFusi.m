function out = analyzeKalatskyFusi(ExpRef)

if nargin<1
    % this is just for debugging
    ExpRef = '2017-10-05_3_CR01';
end

%%
p = getMpepProtocol(ExpRef);

Timeline = getTimeline(ExpRef);

doppler = getDoppler(ExpRef);
nBFPerFrame = 180; % hard-coded for now, should be saved in the doppler structure
bfRate = 1/doppler.dtBF;

% these are the frame onsets
fusiFrameTimes = getFrameTimes(Timeline);
% and these will be the 'middles' of the frames
fusiFrameTimes = fusiFrameTimes + nBFPerFrame/2/bfRate; 
nFramesAcquired = length(fusiFrameTimes);

if (length(doppler.softTimes) ~= nFramesAcquired)
    % Timeline might miss the first few frames
    % Also, the first frame of the movie is acquired before the experiment
    % starts, the way acquisition currently works
    nSkipFrames = length(doppler.softTimes) - nFramesAcquired;
    doppler.frames = doppler.frames(:, :, nSkipFrames+1:end);
    doppler.softTimes = doppler.softTimes(nSkipFrames+1:end);
end

% these are stimulus onset/offset times, as detected from the
% photodiode signal - nStims x nRepeats cell array
stimTimes = getStimTimes(Timeline, p);

% these are indices of frames acquired during the corresponding stimuli
stimFrames = cellfun(@(x) find(fusiFrameTimes>x(1) & fusiFrameTimes<x(2)), stimTimes, 'UniformOutput', false);

pars = getStimPars(p);
nStims = length(pars);
for iStim = 1:nStims
    pars(iStim).xAxis = doppler.xAxis;
    pars(iStim).yAxis = doppler.zAxis;
end

out.ExpRef = ExpRef;
out.pars = pars;
out.meanFrame = mean(doppler.frames, 3);

mov = rmSVD(doppler.frames, 1);

out.averageMov = getAverageMovies(mov, fusiFrameTimes, stimTimes, pars);
out.maps = getPreferenceMaps(mov, fusiFrameTimes, stimTimes, pars);

