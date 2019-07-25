function etaAnalysis(obj)

% stim onset response - all trials
dtCorr = 0.1;
dtFus = 0.05;
tauETA = -2:dtFus:4;
svds2use = 1:500;

aud = obj.stimTimes.audStimPeriodOnOff(:,1);
vis = obj.stimTimes.visStimPeriodOnOff(:,1);
stimOnsetTimes = nanmean([aud, vis], 2); % all trials
aud = obj.stimTimes.audStimPeriodOnOff(:,2);
vis = obj.stimTimes.visStimPeriodOnOff(:,2);
stimOffsetTimes = nanmean([aud, vis], 2); % all trials
blk = obj.stimSequence;
audIdx = blk.audAmplitude ~= 0;
visIdx = blk.visContrast ~= 0;
audLeftIdx = blk.audInitialAzimuth == -60;
audCenterIdx = blk.audInitialAzimuth == 0;
audRightIdx = blk.audInitialAzimuth == 60;
visLeftIdx = blk.visInitialAzimuth == -60;
visRightIdx = blk.visInitialAzimuth == 60;
visOnlyIdx = visIdx & ~audIdx;

movOnsetTimes = obj.stimTimes.movementTimes;
movOnsetTimes = movOnsetTimes(~isnan(movOnsetTimes));
rewardTimes = obj.stimTimes.rewardTimes;
rewardTimes = rewardTimes(~isnan(rewardTimes));

t = 0:dtCorr:max(stimOnsetTimes)+10;
stimT = histcounts(stimOnsetTimes, t);
stimOffT = histcounts(stimOffsetTimes, t);
rewardT = histcounts(rewardTimes, t);
movT = histcounts(movOnsetTimes, t);

maxlag = ceil(max(abs(tauETA))/dtCorr);
zerolag = maxlag+1;
tauCorr = dtCorr*[-maxlag:maxlag];
corrSR = xcorr(rewardT, stimT, maxlag, 'unbiased');
corrSM = xcorr(movT, stimT, maxlag, 'unbiased');
corrMR = xcorr(rewardT, movT, maxlag, 'unbiased');
corrSS = xcorr(stimT, maxlag, 'unbiased');
corrRR = xcorr(rewardT, maxlag, 'unbiased');
corrMM = xcorr(movT, maxlag, 'unbiased');
corrSS(zerolag) = 0;
corrRR(zerolag) = 0;
corrMM(zerolag) = 0;

svds2use = 1:500;
% idx = audLeftIdx;
% [stimETA] = obj.getETA(stimOnsetTimes(idx), tauETA, svds2use);

idxR = visRightIdx;
[stimRETA] = obj.getETA(stimOnsetTimes(idxR), tauETA, svds2use);
idxL = visLeftIdx;
[stimLETA] = obj.getETA(stimOnsetTimes(idxL), tauETA, svds2use);
stimETA = stimRETA - stimLETA;

[stimETA] = obj.getETA(stimOnsetTimes, tauETA, svds2use);
[rewardETA] = obj.getETA(rewardTimes, tauETA, svds2use);
[movETA] = obj.getETA(movOnsetTimes, tauETA, svds2use);
% S = YSLite.svdReg.SdII(svds2use)';
% V = bsxfun(@times, vStimOnset, S);
%%
SVDs2plot = 1:10;
fontSize = 12;
lineWidth = 2;

figure('Position', [400 400 900 400]);
subplot(2, 1, 1)
plot(tauETA, stimETA(:,SVDs2plot), 'LineWidth', lineWidth);
% plot(tau, V(:,5:50));
hold on;
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
plot(xlim, [0 0], 'k:', 'LineWidth', lineWidth)
% set(gca, 'YTickLabels', [], 'XTickLabels', []);
set(gca, 'YTickLabels', [])
xlabel('\tau [s]');
box off;
title('Stim onset @ \tau = 0');
% title('Aud L stim onset @ \tau = 0');
xlimResp = xlim;
set(gca, 'FontSize', fontSize)

subplot(2, 1, 2);
stairs(tauCorr, corrSS, 'LineWidth', lineWidth);
hold on;
stairs(tauCorr, corrSR(:), 'LineWidth', lineWidth);
stairs(tauCorr, corrMR(:), 'LineWidth', lineWidth);
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
legend('Stim Onset', 'Rewards', 'Movement Onset');
xlim(xlimResp)
set(gca, 'YTickLabels', []);
box off;
xlabel('\tau [s]');
set(gca, 'FontSize', fontSize)

figure('Position', [400 400 900 400]);
subplot(2, 1, 1)
plot(tauETA, rewardETA(:,SVDs2plot), 'LineWidth', lineWidth);
% plot(tau, V(:,5:50));
hold on;
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
plot(xlim, [0 0], 'k:', 'LineWidth', lineWidth)
set(gca, 'YTickLabels', [], 'XTickLabels', []);
box off;
title('Reward @ \tau = 0');
xlimResp = xlim;
set(gca, 'FontSize', fontSize)

subplot(2, 1, 2);
stairs(tauCorr, corrRR, 'LineWidth', lineWidth);
hold on;
stairs(tauCorr, flipud(corrSR(:)), 'LineWidth', lineWidth);
stairs(tauCorr, flipud(corrMR(:)), 'LineWidth', lineWidth);
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
legend('Other Rewards', 'Stim Onset', 'Movement Onset');
xlim(xlimResp)
set(gca, 'YTickLabels', []);
box off;
xlabel('\tau [s]');
set(gca, 'FontSize', fontSize)

figure('Position', [400 400 900 400]);
subplot(2, 1, 1)
plot(tauETA, movETA(:,SVDs2plot), 'LineWidth', lineWidth);
% plot(tau, V(:,5:50));
hold on;
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
plot(xlim, [0 0], 'k:', 'LineWidth', lineWidth)
set(gca, 'YTickLabels', [], 'XTickLabels', []);
box off;
title('Movement onset @ \tau = 0');
xlimResp = xlim;
set(gca, 'FontSize', fontSize)

subplot(2, 1, 2);
stairs(tauCorr, corrMM, 'LineWidth', lineWidth);
hold on;
stairs(tauCorr, flipud(corrSM(:)), 'LineWidth', lineWidth);
stairs(tauCorr, corrMR(:), 'LineWidth', lineWidth);
plot([0 0], ylim, 'k:', 'LineWidth', lineWidth)
legend('Movement Onset', 'Stim Onset', 'Rewards');
xlim(xlimResp)
set(gca, 'YTickLabels', []);
box off;
xlabel('\tau [s]');
set(gca, 'FontSize', fontSize)

%%
% figure
% mov(isnan(mov)) = 0;
% imagesc(mean(mov(:, :, tau > -0.5 & tau < 1), 3));
% caxis([-0.1, 0.1])
% colormap(bwrColormap)

%%
% svds2use = 101:500;
U = obj.yStack.svdReg.UdII;
[nz, nx, ns] = size(U);
U = reshape(U, nz*nx, ns);
S = obj.yStack.svdReg.SdII;
% suffices = {'stim', 'move', 'reward'};
suffices = {'test'};
for iSuff = 1
    suffix = suffices{iSuff}
    for firstSVD = 2
        firstSVD
        for lastSVD = 100
            lastSVD
            svds2use = firstSVD:lastSVD;
            switch iSuff
                case 1
                    mov = U(:, svds2use) * diag(S(svds2use)) * stimETA(:, svds2use)';
                case 2
                    mov = U(:, svds2use) * diag(S(svds2use)) * movETA(:, svds2use)';
                case 3
                    mov = U(:, svds2use) * diag(S(svds2use)) * rewardETA(:, svds2use)';
            end
            mov = reshape(mov, nz, nx, []);
            % mov = (mov - clim(1))/diff(clim);
            % mov = max(0, min(1, mov));
            filename = sprintf('%s_%s_%1.0f_%1.0f.gif', obj.ExpRef, suffix, firstSVD, lastSVD);
            makeGIF(obj, tauETA, mov, filename);
        end
    end
end
end

function makeGIF(obj, tauETA, mov, filename)
figure('Color', [1 1 1]);
clim = prctile(mov(:), [1 99]);
clim = [-1 1] * max(abs(clim));
mov(isnan(mov)) = 0;
dtFus = mean(diff(tauETA));

% vw = VideoWriter(sprintf('%s_mov', obj.ExpRef), 'MPEG-4');
% vw.FrameRate = 15;
% vw.Quality = 70;
% open(vw);
firstFrame = true;
for iTau = 1:length(tauETA)
    if tauETA(iTau) < -1 || tauETA(iTau) > 3
        continue;
    end
    imagesc(obj.xAxis, obj.zAxis, mov(:,:,iTau));
    caxis(clim);
    axis off;
    title(sprintf('\\tau = %3.1f [s]', tauETA(iTau)))
    colormap(bwrColormap)
    cb = colorbar;
    cb.Label.String = '\DeltaI/I_0';
    drawnow
    pause(0.01);
    
    %     fr = frame2im(getframe(gcf));
    %     writeVideo(vw, fr);
    [fr, map] = rgb2ind(frame2im(getframe(gcf)), 256, 'nodither');
    if firstFrame
        imwrite(fr, map, filename, 'LoopCount', Inf, 'Delay', dtFus)
        firstFrame = false;
    else
        imwrite(fr, map, filename, 'WriteMode', 'append', 'Delay', dtFus)
    end
    %     pause(0.02);
end
% close(vw)

end



