
svdfFolder = 'Z:\fullDataSamples';
facemapFolder = 'Z:\FaceMapResults';

ExpRefs = {'2019-11-13_3_CR017'; '2019-11-14_2_CR017'; '2019-11-22_2_CR020'};
binSizes = [1, 3, 5];

ExpRef = ExpRefs{3};
binSize = binSizes(3);

[animalName, expDateNum, expNum] = dat.parseExpRef(ExpRef);
expDateStr = datestr(expDateNum, 'yyyy-mm-dd');
filename = sprintf('%s_binSize_%1.0f.mat', ExpRef, binSize);
data = load(fullfile(svdfFolder, filename));
filename = sprintf('%s_%s_faceMapResults.mat', expDateStr, animalName);
res = load(fullfile(facemapFolder, filename));
[~, expInd] = ismember(ExpRef, res.ExpRef);

%%

axFontSize = 18;
[nF, nS, ~] = size(data.svdf);
idxS = 1:nS;
hF = figure('Name', ExpRef, 'Position', [1 1 1920 1080]);

ax1 = subplot(3,4, [1,2,5,6]);
im1 = imagesc(idxS, data.fAxis, log10(mean(data.svdf(:, idxS, :), 3)+eps));
caxis(prctile((log10(data.svdf(:) + eps)), [0.1, 99.9]));
xlabel('iSVD');
ylabel('f [Hz]');
title('Total power');
cb = colorbar;
cb.Label.String = 'log_{10}(Power)';
axis square
ax1.FontSize = axFontSize;

ax2 = subplot(3,4, [3,4,7,8]);
im2 = imagesc(idxS, data.fAxis, log10(mean(data.svdfNormalized(:, idxS, :), 3)+eps));
caxis(prctile((log10(data.svdfNormalized(:) + eps)), [0.1, 99.9]));
xlabel('iSVD');
% ylabel('f [Hz]');
title('Normalized power');
cb = colorbar;
cb.Label.String = 'log_{10}(Power)';
axis square
ax2.FontSize = axFontSize;

ax3 = subplot(3, 4, [9:12]);
tAxis = res.frameTimes{expInd};
motion = res.motionV{expInd}(:, 2);
plot(tAxis, motion, 'LineWidth', 2);
t = data.tAxis(1);
iSample = find((tAxis - t).^2 == min((tAxis - t).^2));
hold on;
hDot = plot(tAxis(iSample), motion(iSample), 'or', 'MarkerSize', 10, 'LineWidth', 3);
xlim(data.tAxis([1, end]));
ylim(ylim);
hLine = plot(ax3, tAxis(iSample)* [1 1], ylim(ax3), 'r:', 'LineWidth', 2);
ax3.FontSize = axFontSize;
xlabel('Time [sec]');
title('Face Motion');
ax3.YTickLabel = [];
drawnow;
pause(1);

nFrames = length(data.tAxis);
mov = getframe(hF);
mov = repmat(mov, nFrames+1, 1);
for iFrame = 1:nFrames
    t = data.tAxis(iFrame);
    iSample = find((tAxis - t).^2 == min((tAxis - t).^2));
    hDot.XData = tAxis(iSample);
    hDot.YData = motion(iSample);
    hLine.XData = tAxis(iSample)* [1 1];
    im1.CData = log10(data.svdf(:, idxS, iFrame) + eps);
    im2.CData = log10(data.svdfNormalized(:, idxS, iFrame) + eps);
    drawnow;
    mov(iFrame + 1) = getframe(hF);
%     pause(0.01);
end

filename = sprintf('%s_binSize_%1.0f.mp4', ExpRef, binSize);
vw = VideoWriter(fullfile(svdfFolder, filename), 'MPEG-4');
vw.Quality = 95;
open(vw);
writeVideo(vw, mov);
close(vw);

close(hF);