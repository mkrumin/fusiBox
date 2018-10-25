function out = getStimTextures(myScreenInfo, pars, xFileName)

myScreenInfo.windowPtr = NaN;
nStims = size(pars, 2);
out = cell(nStims, 1);
[~, mFileName, ~] = fileparts(xFileName);
for iStim = 1:nStims
    ss = feval(mFileName, myScreenInfo, pars(:, iStim));
    stimTextures = cell2mat(reshape(ss.ImageTextures, 1, 1, ss.nImages));

% apply patches for known issues in specific stimulus files here
    switch mFileName
        case 'stimSparseNoiseUncorrAsync_whiteonblack'
            % top row and top column are not actually shown on the screen
            stimTextures = stimTextures(2:end, 2:end, :);
            % In this x-file all the '-1' are clipped during presentation
            % resulting in white squares on black background
            out{iStim} = max(stimTextures, 0);
        otherwise
            out{iStim} = stimTextures;
    end
end
