function ax = plotYStack(res, yy)

doInterpolation = true;
dY = 0.1;

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
xPosAmp = xPosAmp - min(xPosAmp(:));
xPosAmp = xPosAmp/max(xPosAmp(:));
yPosAmp = yPosAmp - min(yPosAmp(:));
yPosAmp = yPosAmp/max(yPosAmp(:));

% the stacks are currently nZ x nX x nY arrays
% we need to make the first dimension to be Y, second - X, and third - Z
meanStack = permute(meanStack, [3 2 1]);
xPosPref = permute(xPosPref, [3 2 1]);
xPosAmp = permute(xPosAmp, [3 2 1]);
yPosPref = permute(yPosPref, [3 2 1]);
yPosAmp = permute(yPosAmp, [3 2 1]);
zAxis = yAxis; % yAxis of the doppler movie is actually zAxis for plotting
yAxis = ySorted;

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

figure;

ax(1) = subplot(1, 3, 1);
hMean = slice(X, Y, Z, meanStack, xAxis, yAxis, zAxis, 'linear');
ax(1).ZDir = 'reverse';
ax(1).CameraViewAngle = 8;
xlabel('x (ML) [mm]')
ylabel('y (AP) [mm]');
zlabel('z (DV) [mm]')

[cMinMax] = prctile(meanStack(:), [1 99]);
caxis(cMinMax);
colormap(ax(1), 'hot')
alphaMean = (meanStack-cMinMax(1))/diff(cMinMax);
% clip the alpha mask to be between 0 and 1
alphaMean = max(min(alphaMean, 1), 0);
alphaMean = 1-alphaMean;
alphaPower = 2;

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

axis equal tight

ax(2) = subplot(1, 3, 2);
hXPos = slice(X, Y, Z, xPosPref, xAxis, yAxis, zAxis, 'linear');
ax(2).ZDir = 'reverse';
ax(2).CameraViewAngle = 8;
xlabel('x (ML) [mm]')
ylabel('y (AP) [mm]');
zlabel('z (DV) [mm]')

[cMinMax] = [0 2*pi]; % res(1).maps.xpos.fovAngles;
caxis(cMinMax);
colormap(ax(2), 'hsv')
alphaXPos = xPosAmp; % max amplitude is the least transparent
% suppress noise
thr = 0.1;
alphaXPos = (alphaXPos-thr)/(1-thr);
alphaXPos = max(alphaXPos, 0);
alphaPower = 2;

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

axis equal tight

ax(3) = subplot(1, 3, 3);
hYPos = slice(X, Y, Z, yPosPref, xAxis, yAxis, zAxis, 'linear');
ax(3).ZDir = 'reverse';
ax(3).CameraViewAngle = 8;
xlabel('x (ML) [mm]')
ylabel('y (AP) [mm]');
zlabel('z (DV) [mm]')

[cMinMax] = [0 2*pi]; % res(1).maps.xpos.fovAngles;
caxis(cMinMax);
colormap(ax(3), 'hsv')
alphaYPos = yPosAmp; % max amplitude is the least transparent
% suppress noise
thr = 0.2;
alphaYPos = (alphaYPos-thr)/(1-thr);
alphaYPos = max(alphaYPos, 0);
alphaPower = 2;

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

axis equal tight

% keyboard;
%%

end
