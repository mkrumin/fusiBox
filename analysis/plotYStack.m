function ax = plotYStack(res, yy)

doInterpolation = true;
dY = 0.1;
alphaPower = 2;
x0 = 6.6;
y0 = 5;
z0 = 2.3;

% build the stacks
nSlices = length(res);
[ySorted, ySortedIdx] = sort(yy, 'ascend');
res = res(ySortedIdx);
meanStack = reshape({res.meanFrame}, 1, 1, nSlices);
meanStack = cell2mat(meanStack);

% keyboard;
%%
[nZ, nX, nSlices] = size(meanStack);
xPosPhase = nan(nZ, nX, nSlices, 'single');
xPosAmp = nan(nZ, nX, nSlices, 'single');
yPosPhase = nan(nZ, nX, nSlices, 'single');
yPosAmp = nan(nZ, nX, nSlices, 'single');
for iSlice=1:nSlices
    xPosPref(:,:,iSlice) = res(iSlice).maps.xpos.prefPhase;
    xPosAmp(:,:,iSlice) = res(iSlice).maps.xpos.amplitude;
    yPosPref(:,:,iSlice) = res(iSlice).maps.ypos.prefPhase;
    yPosAmp(:,:,iSlice) = res(iSlice).maps.ypos.amplitude;
end
% meanStack = xPosPref;
%% 
% crop the stacks and the axes
xAxis = res(1).pars(1).xAxis;
xIdx = find(xAxis>=3 & xAxis <=10);
yAxis = res(1).pars(1).yAxis;
yIdx = find(yAxis>=2);
xAxis = xAxis(xIdx);
yAxis = yAxis(yIdx);
meanStack = meanStack(yIdx, xIdx, :);
xPosPref = xPosPref(yIdx, xIdx, :);
xPosAmp = xPosAmp(yIdx, xIdx, :);
yPosPref = yPosPref(yIdx, xIdx, :);
yPosAmp = yPosAmp(yIdx, xIdx, :);

% Normalize the stacks
meanStack = meanStack - min(meanStack(:));
meanStack = meanStack/max(meanStack(:));
meanStack = 1 - meanStack; % better for plotting
% normalizing xpos and ypos together
minAmp = min([xPosAmp(:); yPosAmp(:)]);
maxAmp = max([xPosAmp(:); yPosAmp(:)]);
xPosAmp = (xPosAmp - minAmp)/(maxAmp-minAmp);
yPosAmp = (yPosAmp - minAmp)/(maxAmp-minAmp);
% alternatively, normalize xpos and ypos separately
% xPosAmp = xPosAmp - min(xPosAmp(:));
% xPosAmp = xPosAmp/max(xPosAmp(:));
% yPosAmp = yPosAmp - min(yPosAmp(:));
% yPosAmp = yPosAmp/max(yPosAmp(:));

% the stacks are currently nZ x nX x nY arrays
% we need to make the first dimension to be Y, second - X, and third - Z
meanStack = permute(meanStack, [3 2 1]);
xPosPref = permute(xPosPref, [3 2 1]);
xPosAmp = permute(xPosAmp, [3 2 1]);
yPosPref = permute(yPosPref, [3 2 1]);
yPosAmp = permute(yPosAmp, [3 2 1]);
zAxis = yAxis; % yAxis of the doppler movie is actually zAxis for plotting
yAxis = ySorted;

% align axes to bregma (approximately)
xAxis = xAxis - x0;
yAxis = yAxis - y0;
zAxis = -(zAxis - z0); % DV coordinates go negative when diving into the brain

% interpolate, if necessary
if doInterpolation
    [Xold, Yold, Zold] = meshgrid(xAxis, yAxis, zAxis);
    yAxis = min(yAxis):dY:max(yAxis);
    [X, Y, Z] = meshgrid(xAxis, yAxis, zAxis);
    meanStack = interp3(Xold, Yold, Zold, meanStack, X, Y, Z);
    xPosPref = interp3(Xold, Yold, Zold, xPosPref, X, Y, Z);
    xPosAmp = interp3(Xold, Yold, Zold, xPosAmp, X, Y, Z);
    yPosPref = interp3(Xold, Yold, Zold, yPosPref, X, Y, Z);
    yPosAmp = interp3(Xold, Yold, Zold, yPosAmp, X, Y, Z);
else
    [X, Y, Z] = meshgrid(xAxis, yAxis, zAxis);
end


%% plotting starts here

hFig = figure;
hFig.Position = [10 200 1900 600];

ax(1) = subplot(1, 3, 1);
hMean = slice(X, Y, Z, meanStack, xAxis, yAxis, zAxis, 'linear');
[cMinMax] = prctile(meanStack(:), [1 99]);
caxis(cMinMax);
colormap(ax(1), 'hot')
alphaMean = (meanStack-cMinMax(1))/diff(cMinMax);
% clip the alpha mask to be between 0 and 1
alphaMean = max(min(alphaMean, 1), 0);
alphaMean = 1-alphaMean;

for i = 1:length(hMean)
    hMean(i).LineStyle = 'none';
    hMean(i).FaceAlpha = 'flat';
    if (max(hMean(i).XData(:)) - min(hMean(i).XData(:))) == 0
        ind = find(xAxis == hMean(i).XData(1));
        hMean(i).AlphaData = squeeze(alphaMean(:, ind, :).^alphaPower);
    elseif (max(hMean(i).YData(:)) - min(hMean(i).YData(:))) == 0
        ind = find(yAxis == hMean(i).YData(1));
        hMean(i).AlphaData = squeeze(alphaMean(ind, :, :).^alphaPower);
    elseif (max(hMean(i).ZData(:)) - min(hMean(i).ZData(:))) == 0
        ind = find(zAxis == hMean(i).ZData(1));
        hMean(i).AlphaData = squeeze(alphaMean(:, :, ind).^alphaPower);
    end
end

% title('Vasculature');
cb(1) = colorbar;
cb(1).Visible = 'off';

ax(2) = subplot(1, 3, 2);
hXPos = slice(X, Y, Z, xPosPref, xAxis, yAxis, zAxis, 'linear');

[cMinMax] = [0 2*pi]; % res(1).maps.xpos.fovAngles;
caxis(cMinMax);
colormap(ax(2), 'hsv')
alphaXPos = xPosAmp; % max amplitude is the least transparent
% suppress noise
thr = 0.1;
alphaXPos = (alphaXPos-thr)/(1-thr);
alphaXPos = max(alphaXPos, 0);

for i = 1:length(hXPos)
    hXPos(i).LineStyle = 'none';
    hXPos(i).FaceAlpha = 'flat';
    if (max(hXPos(i).XData(:)) - min(hXPos(i).XData(:))) == 0
        ind = find(xAxis == hXPos(i).XData(1));
        hXPos(i).AlphaData = squeeze(alphaXPos(:, ind, :).^alphaPower);
    elseif (max(hXPos(i).YData(:)) - min(hXPos(i).YData(:))) == 0
        ind = find(yAxis == hXPos(i).YData(1));
        hXPos(i).AlphaData = squeeze(alphaXPos(ind, :, :).^alphaPower);
    elseif (max(hXPos(i).ZData(:)) - min(hXPos(i).ZData(:))) == 0
        ind = find(zAxis == hXPos(i).ZData(1));
        hXPos(i).AlphaData = squeeze(alphaXPos(:, :, ind).^alphaPower);
    end
end

% title('xpos');
cb(2) = colorbar;
cb(2).Label.String = 'Azimuth [deg]';
cb(2).Ticks = linspace(0 , 2*pi, 7);
cb(2).TickLabels = linspace(res(1).maps.xpos.fovAngles(1), res(1).maps.xpos.fovAngles(2), 7);

ax(3) = subplot(1, 3, 3);
hYPos = slice(X, Y, Z, yPosPref, xAxis, yAxis, zAxis, 'linear');

[cMinMax] = [0 2*pi]; % res(1).maps.xpos.fovAngles;
caxis(cMinMax);
colormap(ax(3), 'hsv')
alphaYPos = yPosAmp; % max amplitude is the least transparent
% suppress noise
thr = 0.15;
alphaYPos = (alphaYPos-thr)/(1-thr);
alphaYPos = max(alphaYPos, 0);

for i = 1:length(hYPos)
    hYPos(i).LineStyle = 'none';
    hYPos(i).FaceAlpha = 'flat';
    if (max(hYPos(i).XData(:)) - min(hYPos(i).XData(:))) == 0
        ind = find(xAxis == hYPos(i).XData(1));
        hYPos(i).AlphaData = squeeze(alphaYPos(:, ind, :).^alphaPower);
    elseif (max(hYPos(i).YData(:)) - min(hYPos(i).YData(:))) == 0
        ind = find(yAxis == hYPos(i).YData(1));
        hYPos(i).AlphaData = squeeze(alphaYPos(ind, :, :).^alphaPower);
    elseif (max(hYPos(i).ZData(:)) - min(hYPos(i).ZData(:))) == 0
        ind = find(zAxis == hYPos(i).ZData(1));
        hYPos(i).AlphaData = squeeze(alphaYPos(:, :, ind).^alphaPower);
    end
end

% title('ypos');
cb(3) = colorbar;
cb(3).Label.String = 'Elevation [deg]';
cb(3).Ticks = linspace(0 , 2*pi, 7);
cb(3).TickLabels = linspace(res(1).maps.ypos.fovAngles(1), res(1).maps.ypos.fovAngles(2), 7);

for i = 1:3
    ax(i).Color = hFig.Color;
    ax(i).XLim = [min(xAxis), max(xAxis)];
    ax(i).YLim = [min(yAxis), max(yAxis)];
    ax(i).ZLim = [min(zAxis), max(zAxis)];
    ax(i).XTick = ceil(min(xAxis)):floor(max(xAxis));
    ax(i).YTick = ceil(min(yAxis)):floor(max(yAxis));
    ax(i).ZTick = ceil(min(zAxis)):floor(max(zAxis));
    ax(i).XTickLabel = '';
    ax(i).YTickLabel = '';
    ax(i).ZTickLabel = '';
    ax(i).DataAspectRatio = [1 1 1];
    ax(i).CameraViewAngle = 9;
    ax(i).Title.FontSize = 14;
    view(ax(i), -30, 20);
    cb(i).Location = 'southoutside';
    cb(i).Label.FontSize = 14;
    cb(i).Label.FontWeight = 'bold';
    cb(i).FontSize = 12;
    cb(i).Box = 'off';
end
% keyboard;
%%

end
