clear
% load('Z:\FaceMapResults\2019-11-26_CR019_faceMapResults.mat');
load('Z:\FaceMapResults\2019-11-21_CR020_faceMapResults.mat');
nExps = length(ExpRef);
for iExp = 1:nExps
    TL = getTimeline(ExpRef{iExp});
    TimelineDuration(iExp) = TL.lastTimestamp;
    lastFrameTime(iExp) = frameTimes{iExp}(end);
    nFrames(iExp) = length(frameTimes{iExp});
    frameRate(iExp) = 1/mean(diff(frameTimes{iExp}));
end

tbl = table(ExpRef, TimelineDuration(:), lastFrameTime(:), nFrames(:), frameRate(:));
tbl.Properties.VariableNames = {'ExpRef', 'TLDuration', 'LastFrameTime', 'nFrames', 'fps'};
tbl



