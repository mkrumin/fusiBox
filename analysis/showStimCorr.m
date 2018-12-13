function showStimCorr(stimCorr, sta, expData)

nStims = length(sta.snipMean);
[nZ, nX, nT, nRepeats] = size(sta.snipAll{1});
dz = mean(diff(expData.doppler.zAxis));
dx = mean(diff(expData.doppler.xAxis));
zAxis = dz*(0:nZ-1);
xAxis = dx*(1:nX);
xAxis = xAxis - mean(xAxis);

% tmp = cell2mat(stimCorr.rho);

clims = [0.1 0.4];
threshold = 0.15;
minSize = 50;
r = 2;

figure('Position', [10 100 1800 900]);
colormap hot;
for iStim = 1:nStims
    ax = subplot(3, nStims, iStim);
    rho = imgaussfilt(stimCorr.rho{iStim}, [1 1]);
    imagesc(xAxis, zAxis, rho);
    caxis(clims);
    axis equal tight
    if iStim == 1
        xlabel('ML [mm]');
        ylabel('DV [mm]');
    end
    ax.FontSize = 14;
    
    highRho = rho > threshold;
    im = bwareaopen(highRho, minSize);
    im = imdilate(im, strel('disk', r));
    im = imerode(im, strel('disk', r));
    
    if sum(im(:))
        
        ax = subplot(3, nStims, iStim + nStims);
        imagesc(xAxis, zAxis, im);
        ax.FontSize = 14;
        axis equal tight
        
        snip = reshape(sta.snipAll{iStim}, nZ*nX, nT, nRepeats);
        traces = squeeze(mean(snip(im(:), :, :)));
        ind0 = find(sta.t == 0);
        traces = bsxfun(@minus, traces, traces(ind0, :));
        ax = subplot(3, nStims, iStim + 2*nStims);
        plot(sta.t, traces, 'k', 'LineWidth', 0.5);
        hold on;
        plot(sta.t, nanmean(traces, 2), 'k', 'LineWidth', 3);
        xlim(ax, [min(sta.t), max(sta.t)]);
        ylim([-0.4, 0.6])
        plot([0 0], ylim, 'r--');
        plot(sta.stimDur(iStim)*[1 1], ylim, 'r--');
        box off;
        xlabel('t [s]')
        ylabel('\DeltaI/I_0');
        ax.FontSize = 14;
    end
end

