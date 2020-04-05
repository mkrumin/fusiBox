function plotFacemapResults(res, saveLocation)

nSVDs = 20;

% plot summary with locations of different ROIs
hFig = plotROISummary(res);
filename = sprintf('ROIs_%s_%s.png', res.expDateStr, res.animalName);
print(hFig, fullfile(saveLocation, filename), '-dpng')
close(hFig);

% plot SVD spatial components
label = {[res.expDateStr, '\_', res.animalName]; 'Global ROI'};
hFig = plotSVDs(res.motionU, res.motionV, nSVDs, res.motionUMask, label);
filename = sprintf('SVDs_%s_%s_GlobalROI.png', res.expDateStr, res.animalName);
print(hFig, fullfile(saveLocation, filename), '-dpng')
close(hFig);
for iLocal = 1:length(res.localROIs)
    label = {[res.expDateStr, '\_', res.animalName]; ['Local ROI #', num2str(iLocal)]};
    hFig = plotSVDs(res.localROIs(iLocal).motionU, res.localROIs(iLocal).motionV, ...
        nSVDs, res.localROIs(iLocal).motionUMask, label);
    filename = sprintf('SVDs_%s_%s_LocalROI#%g.png', res.expDateStr, res.animalName, iLocal);
    print(hFig, fullfile(saveLocation, filename), '-dpng')
    close(hFig);
end

% plot SVDs with temporal traces, separate by experiment
nSVDs = 8;
for iExp = 1:length(res.ExpRef)
    hFig = plotSVDTraces(res.ExpRef{iExp}, res.motionU(:, 1:nSVDs), ...
        res.motionV{iExp}(:, 1:nSVDs), res.frameTimes{iExp}, ...
        res.motionUMask, 'Global ROI');
    filename = sprintf('Traces_%s_GlobalROI.png', res.ExpRef{iExp});
    print(hFig, fullfile(saveLocation, filename), '-dpng')
    close(hFig);
    for iLoc = 1:length(res.localROIs)
        hFig = plotSVDTraces(res.ExpRef{iExp}, res.localROIs(iLoc).motionU(:, 1:nSVDs), ...
            res.localROIs(iLoc).motionV{iExp}(:, 1:nSVDs), res.frameTimes{iExp}, ...
            res.localROIs(iLoc).motionUMask, ['Local ROI #', num2str(iLoc)]);
        filename = sprintf('Traces_%s_LocalROI#%1.0f.png', res.ExpRef{iExp}, iLoc);
        print(hFig, fullfile(saveLocation, filename), '-dpng')
        close(hFig);
    end
end

end % main()

% =================================================================
function hF = plotROISummary(res)
hF = figure;
ax = subplot(2, 2, 1);
imagesc(res.meanFrame);
colormap(ax, 'gray')
axis off equal
title({[res.expDateStr, '\_', res.animalName]; 'Mean Frame'});

ax = subplot(2, 2, 2);
imagesc(res.meanMotion);
colormap(ax, 'hot')
axis off equal
title('Average Motion');

ax = subplot(2, 2, 3);
imagesc(res.motionAvg)
colormap(ax, 'hot')
axis off equal
title('Global ROI');

ax = subplot(2, 2, 4);
im = nansum(cell2mat(reshape({res.localROIs.motionAvg}, 1, 1, [])), 3);
imagesc(im)
colormap(ax, 'hot')
axis off equal
title('Local ROIs');
drawnow;
end

% ==========================================================
function [hF] = plotSVDs(U, V, nSVDs, UMask, lbl)
hF = figure('Position', [1 1 1920 1080]);
nRows = floor(sqrt(nSVDs));
nColumns = ceil(nSVDs/nRows);
% lambdas = std(cell2mat([res.motionV]));
lambdas = sqrt(mean(cell2mat([V]).^2));
for iSVD = 1:nSVDs
    ax = subplot(nRows, nColumns, iSVD);
    mask = nan(size(UMask));
    mask(UMask(:)) = U(:,iSVD);
    mask(isnan(mask)) = 0;
    imagesc(mask)
    colormap(ax, 'redblue')
    caxis(ax, max(abs(mask(:))) * [-1 1])
    axis off equal
    xlim(ax, [find(sum(UMask), 1, 'first'), find(sum(UMask), 1, 'last')]);
    ylim(ax, [find(sum(UMask, 2), 1, 'first'), find(sum(UMask, 2), 1, 'last')]);
    title(sprintf('#%1.0f: rms=%3.1f', iSVD, lambdas(iSVD)));
    if iSVD == 1
        ax.Visible = 'on';
        ax.Box = 'off';
        ax.XTick = [];
        ax.YTick = [];
        ax.XColor = hF.Color;
        ax.YColor = hF.Color;
        ylabel(ax, lbl, 'FontWeight', 'bold', 'Color', 'k')
    end
    %     colorbar
end
drawnow;
end

% ====================================================================
function hF = plotSVDTraces(ExpRef, U, V, t, UMask, lbl)

nSVDs = size(U, 2);
hF = figure('Position', [1 1 1920 1080]);
nRows = nSVDs;
nColumns = 10;
% lambdas = std(cell2mat([res.motionV]));
lambdas = sqrt(mean(V.^2));
for iSVD = 1:nSVDs
    ax = subplot(nRows, nColumns, 1 + nColumns*(iSVD - 1));
    mask = nan(size(UMask));
    mask(UMask(:)) = U(:,iSVD);
    mask(isnan(mask)) = 0;
    imagesc(mask)
    colormap(ax, 'redblue')
    caxis(ax, max(abs(mask(:))) * [-1 1])
    axis off equal
    xlim(ax, [find(sum(UMask), 1, 'first'), find(sum(UMask), 1, 'last')]);
    ylim(ax, [find(sum(UMask, 2), 1, 'first'), find(sum(UMask, 2), 1, 'last')]);
    ax.Visible = 'on';
    ax.Box = 'off';
    ax.XTick = [];
    ax.YTick = [];
    ax.XColor = hF.Color;
    ax.YColor = hF.Color;
    ylabel(ax, sprintf('# %1.0f', iSVD), ...
        'FontWeight', 'bold', 'Color', 'k', 'FontSize', 14)
    if iSVD == 1
        title(ax, {strrep(ExpRef, '_', '\_'); lbl}, 'FontSize', 12);
    end
    
    ax = subplot(nRows, nColumns, [2:nColumns-1] + nColumns*(iSVD - 1));
    plot(t, V(:, iSVD), 'LineWidth', 1);
    axis off tight
    hold on;
    % plot a dotted line for zero
    plot(xlim, [0 0], 'k:');
    if iSVD == 1
        % plot a 1 minute long scale bar and annotate it
        plot([-60, 0] + t(end), ax.YLim(2)*[1 1], 'k', 'LineWidth', 5);
        text(t(end), ax.YLim(2), '1 min', 'HorizontalAlignment', 'Right', ...
            'VerticalAlignment', 'Bottom', 'FontSize', 14);
    end
    
    ax = subplot(nRows, nColumns, nColumns*iSVD);
    xlim([-1 1]);
    ylim([-1 1]);
    axis off;
    text(0, 0, sprintf('%3.1f', lambdas(iSVD)), 'FontSize', 16, ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle');
    if iSVD == 1
        title('rms', 'FontSize', 14);
    end
    
    %     colorbar
end
drawnow;
end