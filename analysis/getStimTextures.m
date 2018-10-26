function out = getStimTextures(myScreenInfo, pars, xFileName)

myScreenInfo.windowPtr = NaN;
nStims = size(pars, 2);
out = cell(nStims, 1);
[~, mFileName, ~] = fileparts(xFileName);
for iStim = 1:nStims
    ss = feval(mFileName, myScreenInfo, pars(:, iStim));
    out{iStim}.stimTextures = ss.ImageTextures;
    out{iStim}.textureSequence = ss.ImageSequence(:);
    
    % apply patches for known issues in specific stimulus files here
    switch mFileName
        case 'stimSparseNoiseUncorrAsync_whiteonblack'
            for iTexture = 1:length(out{iStim}.stimTextures)
                % top row and top column are not actually shown on the screen
                % In this x-file all the '-1' are clipped during presentation
                % resulting in white squares on black background
                out{iStim}.stimTextures{iTexture} = ...
                    max(out{iStim}.stimTextures{iTexture}(2:end, 2:end, :), 0);
            end
        otherwise
            % do nothing
    end
end
