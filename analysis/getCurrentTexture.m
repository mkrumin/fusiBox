function texture = getCurrentTexture(t, stim, stimTimes, frameTimes, hwInfo)

tmp = cell2mat(stimTimes);
stimOnsets = tmp(:, 1:2:end);
stimOffsets = tmp(:, 2:2:end);

stimIdx = stimOnsets<t & stimOffsets>t;

decFactor = 16;
nY = ceil(hwInfo.ScreenRect(4)/decFactor);
nX = ceil(hwInfo.ScreenRect(3)/decFactor);
texture = zeros(nY, nX);

[iStim, iRepeat] = ind2sub(size(stimTimes), find(stimIdx));

if ~isempty(iStim)
    [~, iFrame] = min(abs(frameTimes{iStim, iRepeat} - t));
    % making sure it is within the legal range
    iFrame = min(max(1, iFrame), length(stim{iStim}.textureSequence));
    
    rows = ceil((stim{iStim}.DestRects([2,4], iFrame) + [1; 1])/decFactor);
    columns = ceil((stim{iStim}.DestRects([1,3], iFrame) + [1; 1])/decFactor);
    iTexture = stim{iStim}.textureSequence(iFrame);
    subtexture = imresize(stim{iStim}.stimTextures{iTexture}, [diff(rows)+1, diff(columns)+1], 'nearest');
    % the next line works well for MinusOneToOne == 1, should be tested for MOTO == 0
    subtexture = subtexture * stim{iStim}.Amplitudes(iFrame) * 2;
    texture(rows(1):rows(2), columns(1):columns(2)) = subtexture(:,:,1);
end
