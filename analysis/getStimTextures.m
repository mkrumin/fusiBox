function out = getStimTextures(myScreenInfo, pars)

myScreenInfo.windowPtr = NaN;
nStims = size(pars, 2);
out = cell(nStims, 1);
for iStim = 1:nStims
    % the function now is hardcoded, but should ideally be read from the p-file
    ss = stimSparseNoiseUncorrAsync_whiteonblack(myScreenInfo, pars(:, iStim));
    stimTextures = cell2mat(reshape(ss.ImageTextures, 1, 1, ss.nImages));

    % top row and top coumn are not actually shown on the screen
    stimTextures = stimTextures(2:end, 2:end, :);
    
    % In this x-file all the '-1' are clipped during presentation
    % resulting in white squares on black background
    out{iStim} = max(stimTextures, 0);
end
