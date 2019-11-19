function ax = plotYStack(res, yy)

doInterpolation = false;
dY = 0.1;
alphaPower = 1.5;
alphaThr = 0.2;
alphaPowerMean = 2.5;
<<<<<<< HEAD
x0 = 6.6;
y0 = 5;
z0 = 0;
=======

% x0 = 6.6;
% y0 = 5;
% z0 = 1.5;
x0 = 6.7;
y0 = 0;
z0 = 0;
zMin = 0.2;
xMin = 2.5;
xMax = 11;

ampFilterStd = [0.5 0.5 0.1] * 2;
prefFilterStd = [0.5 0.5 0.1];
>>>>>>> refs/remotes/origin/master

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
<<<<<<< HEAD
xIdx = find(xAxis>=0 & xAxis <=12);
yAxis = res(1).pars(1).yAxis;
yIdx = find(yAxis>=0);
=======
xIdx = find(xAxis>=xMin & xAxis <=xMax);
zAxis = res(1).pars(1).yAxis;
zIdx = find(zAxis>=zMin);
>>>>>>> refs/remotes/origin/master
xAxis = xAxis(xIdx);
zAxis = zAxis(zIdx);
meanStack = meanStack(zIdx, xIdx, :);
xPosPref = xPosPref(zIdx, xIdx, :);
xPosAmp = xPosAmp(zIdx, xIdx, :);
yPosPref = yPosPref(zIdx, xIdx, :);
yPosAmp = yPosAmp(zIdx, xIdx, :);

yPosPref = imgaussfilt3(yPosPref, prefFilterStd);
xPosPref = imgaussfilt3(xPosPref, prefFilterStd);

% Normalize the stacks
meanStack = meanStack - min(meanStack(:));
meanStack = meanStack/max(meanStack(:));
meanStack = 1 - meanStack; % better for plotting
% normalizing xpos and ypos together
xPosAmp = imgaussfilt3(xPosAmp, ampFilterStd);
yPosAmp = imgaussfilt3(yPosAmp, ampFilterStd);
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
hFig.Position = [0 100 1920 720];

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
        hMean(i).AlphaData = squeeze(alphaMean(:, ind, :).^alphaPowerMean);
    elseif (max(hMean(i).YData(:)) - min(hMean(i).YData(:))) == 0
        ind = find(yAxis == hMean(i).YData(1));
        hMean(i).AlphaData = squeeze(alphaMean(ind, :, :).^alphaPowerMean);
    elseif (max(hMean(i).ZData(:)) - min(hMean(i).ZData(:))) == 0
        ind = find(zAxis == hMean(i).ZData(1));
        hMean(i).AlphaData = squeeze(alphaMean(:, :, ind).^alphaPowerMean);
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
thr = alphaThr;
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
thr = alphaThr;
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

% return;
%% Make a figure with all the slices as separate panels

nSlices = length(yAxis);
alphaPower = 0.5;
meanStack = -meanStack.^(1/2);
for iSlice = nSlices:-1:1
    h = figure('Name', sprintf('Slice #%g', iSlice));
    h.Position = [100 100 1700 750];
    h.Color = [1 1 1];
    
    % plotting vasculature
    ah(1) = subplot(1, 3, 1);
    im = squeeze(meanStack(iSlice,:,:))';
    imh = imagesc(xAxis, zAxis, im);
    colormap(ah(1), 'hot');
    %     imh.AlphaData = 1-im;
    %     imh.AlphaDataMapping = 'scaled';
    axis equal tight
    caxis(prctile(im(:), [5 99]))
    cb = colorbar;
    cb.Location = 'southoutside';
    cb.Visible = 'off';
    cb = colorbar;
    cb.Location = 'eastoutside';
    cb.Visible = 'off';

    
    title('Vasculature', 'FontSize', 14)
    tx = text(min(xlim) - 1.5, mean(ylim), sprintf('AP = %4.2f [mm]', yAxis(iSlice)));
    tx.HorizontalAlignment = 'Right';
    tx.VerticalAlignment = 'Middle';
    tx.FontSize = 14;
    tx.FontWeight = 'bold';
    
    % plotting xpos
    ah(2) = subplot(1, 3, 2);
    im = squeeze(xPosPref(iSlice,:,:))';
    imh = imagesc(xAxis, zAxis, im);
    colormap(ah(2), 'hsv');
    imh.AlphaData = squeeze(alphaXPos(iSlice,:,:))'.^alphaPower;
    imh.AlphaDataMapping = 'scaled';
    axis equal tight
    caxis([0 2*pi]);
    cb = colorbar;
    cb.Location = 'southoutside';
    cb.FontSize = 12;
    cb.Ticks = linspace(0, 2*pi, 7);
    cb.TickLabels = linspace(-135, 135, 7);
    cb.Label.String = 'Azimuth [deg]';
    cb.Label.FontSize = 14;

    cb = colorbar;
    cb.Location = 'eastoutside';
    cb.Visible = 'off';
    
    title('xpos', 'FontSize', 14)

    % plotting ypos
    ah(3) = subplot(1, 3, 3);
    im = squeeze(yPosPref(iSlice,:,:))';
    imh = imagesc(xAxis, zAxis, im);
    colormap(ah(3), 'hsv');
    imh.AlphaData = squeeze(alphaYPos(iSlice,:,:))'.^alphaPower;
    imh.AlphaDataMapping = 'scaled';
    axis equal tight
    caxis([0 2*pi]);
    cb = colorbar;
    cb.Location = 'southoutside';
    cb.Visible = 'off';

    cb = colorbar;
    cb.Location = 'eastoutside';
    cb.FontSize = 12;
    cb.Ticks = linspace(0, 2*pi, 7);
    cb.TickLabels = linspace(45, -45, 7);
    cb.Label.String = 'Elevation [deg]';
    cb.Label.FontSize = 14;
    
    title('ypos', 'FontSize', 14)

    for i = 1:length(ah)
        ah(i).FontSize = 12;
        ah(i).YDir = 'normal';
        ah(i).Color = h.Color;
        ah(i).XLim = [min(xAxis), max(xAxis)];
        ah(i).YLim = [min(zAxis), max(zAxis)];
        ah(i).XTick = ceil(min(xAxis)):floor(max(xAxis));
        ah(i).YTick = ceil(min(zAxis)):floor(max(zAxis));
        xlabel(ah(i), 'ML [mm]', 'FontSize', 14);
        ylabel(ah(i), 'DV [mm]', 'FontSize', 14);
        ah(i).Box = 'off';
        ah(i).XGrid = 'off';
        ah(i).YGrid = 'off';
    end
    
%     drawnow;
%     pause(0.5);
%     filename = sprintf('CR01_2017-11-17_AP%4.2f.eps', yAxis(iSlice));
%     saveas(h, filename, 'epsc');
end

return
%%
YStack = struct;
YStack.ExpRef = '2017-11-17_CR01';
YStack.xAxis = xAxis;
YStack.yAxis = yAxis;
YStack.zAxis = zAxis;
YStack.meanDoppler = permute(meanStack, [3, 2, 1]);
YStack.xPos = permute(xPosPref, [3, 2, 1])/(2 * pi) * 270 - 135;
YStack.xPosAlpha = permute(alphaXPos, [3, 2, 1]).^alphaPower;
YStack.yPos = permute(yPosPref, [3, 2, 1])/(2 * pi) * 90 - 45;
YStack.yPosAlpha = permute(alphaYPos, [3, 2, 1]).^alphaPower;
% save('2017-11-17_CR01_Retinotopy.mat', '-struct', 'YStack', '-v7.3', '-nocompression')

end
