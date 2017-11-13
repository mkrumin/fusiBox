function out = getStimTextures(myScreenInfo, pars)

myScreenInfo.windowPtr = NaN;
ss = stimSparseNoiseUncorrAsync_whiteonblack(myScreenInfo, pars);
stimTextures = cell2mat(reshape(ss.ImageTextures, 1, 1, ss.nImages));
% top row and top coumn are not actually shown on the screen
stimTextures = stimTextures(2:end, 2:end, :);

% In this x-file all the '-1' are clipped during presentation
% resulting in white squares on black background
out = max(stimTextures, 0);
