function out = calcRF(stimT, stim, movT, mov)

[nStims, nRepeats] = size(stimT);

[nZ, nX, nFrames] = size(mov);
nVoxels = nZ*nX; % in the data movie
movFlat = reshape(mov, nVoxels, nFrames)';

kernel = cell(nStims, nRepeats);
tau = [-3:0.2:3]';
for iStim = 1:nStims
    [nRows, nColumns, nTextures] = size(stim{iStim});
    nPixels = nRows * nColumns; % in the stimulus textures
    onsets = cat(1, zeros(1, nPixels), ...
        diff(reshape(stim{iStim}, nPixels, nTextures)'));
    for iRepeat = 1:nRepeats
        kernel{iStim, iRepeat} = getETA(stimT{iStim, iRepeat}, ...
            onsets, movT, movFlat, tau);
    end
end

end % calcRF()
%% ================================================================

function eta = getETA(eventT, events, dataT, data, tau)
    nLags = numel(tau);
    nPixels = size(events, 2);
    nVoxels = size(data, 2);
    eta = zeros(nLags, nVoxels, nPixels, 'single');
    for iPixel = 1:nPixels
        eTimes = eventT(events(:, iPixel) == 1);
        nEvents = sum(events(:, iPixel) == 1);
        allTimes = bsxfun(@plus, eTimes, tau(:)');
        allSnippets = interp1(dataT, data, allTimes(:));
        allSnippets = reshape(allSnippets, nEvents, nLags, nVoxels);
        pixelResponse = permute(nanmean(allSnippets), [2 3 1]);
        eta(:, :, iPixel) = pixelResponse;
    end
end % getETA()

