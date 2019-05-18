function h = plotPreferenceMaps(maps, p, plotHemo, plotType)

if nargin<3 || isempty(plotHemo)
    plotHemo = false;
end

if nargin<4 || ~ismember(plotType, {'alpha', 'saturation'})
    plotType = 'alpha';
    %     plotType = 'saturation'
end

if plotHemo
    nRows = 2;
else
    nRows = 1;
end
nColumns = 2;

alphaPower = 1.5;
filterSize = 1;
%% plot the preference maps
h = figure;

ampMax = max([maps.xpos.amplitude(:); maps.ypos.amplitude(:)]);

subplot(nRows, nColumns, 1)
phase = maps.xpos.prefPhase;
amp = maps.xpos.amplitude;
[nz, nx] = size(phase);
switch plotType
    case 'saturation'
        compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), amp(:)/ampMax]);
        compound = reshape(compound, nz, nx, 3);
        imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
    case 'alpha'
        compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), ones(size(amp(:)))]);
        compound = reshape(compound, nz, nx, 3);
        im = imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
        im.AlphaData = imgaussfilt((amp/ampMax), filterSize).^alphaPower;
        im.AlphaDataMapping = 'none';
        box off;
end
startPos = maps.xpos.fovAngles(1);
endPos = maps.xpos.fovAngles(2);
colormap hsv
c = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), 'Location', 'southoutside');
c.Label.String = 'Azimuth [deg]';
c.Label.FontSize = 12;

cDummy = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), ...
    'Location', 'eastoutside', 'Visible', 'off');
% colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(0, p(1).cycleDuration, 7));
title('xpos');
xlabel('X [mm]');
ylabel('Depth [mm]');
axis equal tight


subplot(nRows, nColumns, 2)
phase = maps.ypos.prefPhase;
amp = maps.ypos.amplitude;
[nz, nx] = size(phase);
switch plotType
    case 'saturation'
        compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), amp(:)/ampMax]);
        compound = reshape(compound, nz, nx, 3);
        imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
    case 'alpha'
        compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), ones(size(amp(:)))]);
        compound = reshape(compound, nz, nx, 3);
        im = imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
        im.AlphaData = imgaussfilt((amp/ampMax), filterSize).^alphaPower;
        im.AlphaDataMapping = 'none';
        box off;
end
startPos = maps.ypos.fovAngles(1);
endPos = maps.ypos.fovAngles(2);
colormap hsv
c = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), ...
    'Location', 'eastoutside');
c.Label.String = 'Elevation [deg]';
c.Label.FontSize = 12;

cDummy = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), ...
    'Location', 'southoutside', 'Visible', 'off');
% colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(0, p(3).cycleDuration, 7));
title('ypos');
xlabel('X [mm]');
ylabel('Depth [mm]');
axis equal tight

%% plot the hemodynamic delay

if plotHemo
    %     h(end+1) = figure;
    subplot(nRows, nColumns, 3)
    phase = maps.xpos.hemoPhase;
    amp = maps.xpos.amplitude;
    [nz, nx] = size(phase);
    switch plotType
        case 'saturation'
            compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), amp(:)/ampMax]);
            compound = reshape(compound, nz, nx, 3);
            imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
        case 'alpha'
            compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), ones(size(amp(:)))]);
            compound = reshape(compound, nz, nx, 3);
            im = imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
            im.AlphaData = imgaussfilt((amp/ampMax), filterSize).^alphaPower;
            im.AlphaDataMapping = 'none';
            box off;
    end
    colormap hsv
    
    xposStims = find(ismember({p.orientation}, 'xpos'));
    ticks = [0:2:8];
    c = colorbar('Ticks', ticks/p(xposStims(1)).cycleDuration, 'TickLabels', ticks, 'Location', 'eastoutside');
    c.Label.String = 'Hemodynamic Delay [sec]';
    c.Label.FontSize = 12;
    
    cDummy = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), ...
        'Location', 'southoutside', 'Visible', 'off');
    
    title('xpos');
    xlabel('X [mm]');
    ylabel('Depth [mm]');
    axis equal tight
    
    
    subplot(nRows, nColumns, 4)
    phase = maps.ypos.hemoPhase;
    amp = maps.ypos.amplitude;
    [nz, nx] = size(phase);
    switch plotType
        case 'saturation'
            compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), amp(:)/ampMax]);
            compound = reshape(compound, nz, nx, 3);
            imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
        case 'alpha'
            compound = hsv2rgb([phase(:)/(2*pi), ones(size(phase(:))), ones(size(amp(:)))]);
            compound = reshape(compound, nz, nx, 3);
            im = imagesc(p(1).xAxis, p(1).yAxis, imgaussfilt(compound, filterSize));
            im.AlphaData = imgaussfilt((amp/ampMax), filterSize).^alphaPower;
            im.AlphaDataMapping = 'none';
            box off;
    end
    colormap hsv
    
    yposStims = find(ismember({p.orientation}, 'ypos'));
    ticks = [0:2:8];
    c = colorbar('Ticks', ticks/p(yposStims(1)).cycleDuration, 'TickLabels', ticks, 'Location', 'eastoutside');
    c.Label.String = 'Hemodynamic Delay [sec]';
    c.Label.FontSize = 12;
    
    cDummy = colorbar('Ticks', linspace(0, 1, 7), 'TickLabels', linspace(startPos, endPos, 7), ...
        'Location', 'southoutside', 'Visible', 'off');
    
    title('ypos');
    xlabel('X [mm]');
    ylabel('Depth [mm]');
    axis equal tight
end