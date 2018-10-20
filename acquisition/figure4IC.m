
SCAN.Bmode(1);
BM = SCAN.I0;
[xAxisDop, zAxisDop, dtDop] = SCAN.getAxis('DLQ');
[xAxisBM, zAxisBM, dtBM] = SCAN.getAxis('BM');

c = SCAN.parSeq.c * 1e6; % [mm/sec]

SCAN.Doppler('DLQ')
RF = SCAN.RF{1};
BF = SCAN.BF{1};
BFFilt = SCAN.BFfilt;
DOP = SCAN.I0;

%%

c = SCAN.parSeq.c * 1e6; % [mm/sec]
dtRF = dtBM(3);
[nT, nCh, ~] = size(RF);
travelTime = zAxisBM*2/c;
rfSamplesAxis = travelTime/dtBM(3);
clims = [-2^13, 2^13];

dtX = 0.1/c;

figure
a = subplot(1, 2, 1);
imagesc(1:128, dtRF*(1:nT), RF(:,:,3)),
caxis(clims);
ylim([min(travelTime), max(travelTime)]);
colormap gray
xlabel('Channel #');
ylabel('Travel Time [sec]');
a.XTick = [1 32 64 96 128];
title('RF data');

a = subplot(1, 2, 2);
imagesc(xAxisBM, zAxisBM, BM)
a.XTick = [0:2:12];
a.YTick = [0:5];
xlabel('x [mm]');
ylabel('depth [mm]');
axis equal tight
xlim(xlim);
ylim(ylim);
title('B-Mode image');

figure
for iWave = 1:5
    a = subplot(1, 5, iWave);
    imagesc(1:128, dtRF*(1:nT), RF(:,:,iWave))
    ylim([min(travelTime), max(travelTime)]);
    
    colormap gray
    caxis(clims);
    if iWave ==3
        a.XTick = [1 32 64 96 128];
        xlabel('Channel #');
        ylabel('Travel Time [sec]')
    else
        a.XTick = [];
        a.YTick = [];
    end
end

figure
im = abs(BF(:,:,1));
imagesc(xAxisDop, zAxisDop, im)
colormap gray
caxis(prctile(im(:), [0 99.7]))
colorbar
a = gca;
a.XTick = [0:2:12];
a.YTick = [0:5];
xlabel('x [mm]');
ylabel('depth [mm]');
axis equal tight
xlim(xlim);
ylim(ylim);
title('after coherent beamforming');

figure
im = squeeze(abs(BFFilt(20,:,:)));
% im = DOP;
imagesc(xAxisDop, zAxisDop, im)
colormap gray
caxis(prctile(im(:), [0 99.7]))
colorbar
a = gca;
a.XTick = [0:2:12];
a.YTick = [0:5];
xlabel('x [mm]');
ylabel('depth [mm]');
axis equal tight
xlim(xlim);
ylim(ylim);
title('after HP and SVD filter');

figure
im = squeeze(sqrt(mean(abs(BFFilt(20:70,:,:)).^2)));
% im = DOP;
imagesc(xAxisDop, zAxisDop, im)
colormap gray
caxis(prctile(im(:), [0 99.7]))
colorbar
a = gca;
a.XTick = [0:2:12];
a.YTick = [0:5];
xlabel('x [mm]');
ylabel('depth [mm]');
axis equal tight
xlim(xlim);
ylim(ylim);
title('Doppler signal (100 ms, 50 BF frames)');
