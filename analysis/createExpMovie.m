function F = createExpMovie(dataIn)

mov = dataIn.doppler.frames;
% xIdx = dataIn.doppler.xAxis>=2 & dataIn.doppler.xAxis <=10.8;
xIdx = dataIn.doppler.xAxis>=2.4 & dataIn.doppler.xAxis <=10.4;
xMean = mean(dataIn.doppler.xAxis(xIdx));
zIdx = dataIn.doppler.zAxis>=0.2;
mov = mov(zIdx, xIdx, ~dataIn.idxOutliers);
tAxis = dataIn.fusiFrameTimes(~dataIn.idxOutliers);
I0 = prctile(mov, 50, 3);
mov = bsxfun(@minus, mov, I0);
mov = bsxfun(@rdivide, mov, I0);
mov = imgaussfilt3(mov, [1, 1, 1]);
% mov = rmSVD(mov, 1);
% mov = imgaussfilt(mov, [1, 1]);
minMov = min(mov(:));
mov = log(mov-minMov+1);

nRows = 3;
nColumns = 1;
hFig = figure('Position', [100 100 450 900]);
cropRect = [1 75 450 750];
axScreen = subplot(nRows, nColumns, 1);
currTexture = getCurrentTexture(1, dataIn.stim, dataIn.stimTimes, dataIn.stimFrameTimes, dataIn.hwInfo);
hTexture = imagesc(currTexture*0);
caxis([-1 1]);
colormap(axScreen, 'gray');
hTitle = title(sprintf('t = %3.1f [s]', 0));
axis equal tight off
cbFake = colorbar;
cbFake.Visible = 'off';


ax = subplot(nRows, nColumns, 2);
hIm = imagesc(dataIn.doppler.xAxis(xIdx) - xMean, dataIn.doppler.zAxis(zIdx), log(mean(dataIn.doppler.frames(zIdx, xIdx, :), 3)));
axis equal tight
colormap(ax, 'hot')
box off;
xlabel('ML axis [mm]');
ylabel('DV axis [mm]');
title(sprintf('y = %3.1f [mm]', dataIn.doppler.motorPosition))
ax.YTick = 1:5;
cb = colorbar;
cb.Visible = 'off';


axEye = subplot(nRows, nColumns, 3);
eyeFrame = read(dataIn.eyeMovie, 1);
hEye = imagesc(eyeFrame);
caxis(axEye, prctile(double(eyeFrame(:)), [0 99]));
axis equal tight off
colormap(axEye, 'gray')
box off;
cbEye = colorbar;
cbEye.Visible = 'off';

drawnow;
F = repmat(getframe(hFig, cropRect), 1, 30);
pause(3);

mm = prctile(mov(:), [1 99.95]);
for iFrame = 1:size(mov, 3)
    if iFrame==1
        hIm.CData = mov(:,:,iFrame);
        caxis(ax, mm);
        cb.Visible = 'on';
        cb.TickLabels = round((cellfun(@exp, cellfun(@str2double, cb.TickLabels, 'UniformOutput', false))...
            - 1 + minMov) * 100);
        hT = text(ax, max(xlim(ax)) + 2, 3.25, '\DeltaI/I_0 [%]');
        hT.Rotation = 90;
        hT.HorizontalAlignment = 'Center';
        hT.VerticalAlignment = 'Top';
        hT.FontSize = 12;
        hT.FontWeight = 'bold';
    else
        hIm.CData = mov(:,:,iFrame);
        hTitle.String = sprintf('t = %3.1f [s]', tAxis(iFrame));
        [~, ind] = min(abs(dataIn.eyeTimes - tAxis(iFrame)));
        hEye.CData = read(dataIn.eyeMovie, ind);
    end
    currTexture = getCurrentTexture(tAxis(iFrame), dataIn.stim, dataIn.stimTimes, dataIn.stimFrameTimes, dataIn.hwInfo);
    hTexture.CData = currTexture;
    drawnow
    pause(0.01)
    F(end+1) = getframe(hFig, cropRect);
end

hIm.CData = log(mean(dataIn.doppler.frames(zIdx, xIdx, :), 3));
caxis(ax, 'auto')
cb.Visible = 'off';
hT.Visible = 'off';
drawnow;
F(end+1) = getframe(hFig, cropRect);
pause(3);
