function texture = getCurrentTexture(t, stim, stimTimes, frameTimes, hwInfo)

tmp = cell2mat(stimTimes);
stimOnsets = tmp(:, 1:2:end);
stimOffsets = tmp(:, 2:2:end);

stimIdx = stimOnsets<t & stimOffsets>t;

decFactor = 10;
nY = ceil(hwInfo.ScreenRect(4)/decFactor);
nX = ceil(hwInfo.ScreenRect(3)/decFactor);
texture = zeros(nY, nX, 'uint8');

[iStim, iRepeat] = ind2sub(size(stimTimes), find(stimIdx));

if ~isempty(iStim)
    [~, iFrame] = min(abs(frameTimes{iStim, iRepeat} - t));
    % making sure it is within the legal range
    iFrame = min(max(1, iFrame), length(stim{iStim}.stimTextures));
    
    rows = ceil(stim{iStim}.DestRects([2,4], iFrame)/decFactor);
    columns = ceil(stim{iStim}.DestRects([1,3], iFrame)/decFactor);
    subtexture = imresize(stim{iStim}.stimTextures{iFrame}, [diff(rows)+1, diff(columns)+1], 'nearest');
    texture(rows(1):rows(2), columns(1):columns(2)) = subtexture;
end
