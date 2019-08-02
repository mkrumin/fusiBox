clim = [0 10]*1e-3;
xInd = [30:110];
zInd = [15:126];

figure
load('\\zserver.cortexlab.net\Data\Subjects\CR015\2019-08-01\1808\2019-08-01_1808_CR015_13NPTracing.mat');
subplot(2, 2, 1)
imagesc(Doppler.xAxis(xInd), Doppler.zAxis(zInd), sqrt(min(Doppler.yStack(zInd, xInd, :), [], 3)));
axis equal tight
colormap hot
caxis(clim);
title('y = 1.3mm, MIN projection')
ylabel('z [mm]');

subplot(2, 2, 2)
imagesc(Doppler.xAxis(xInd), Doppler.zAxis(zInd), sqrt(max(Doppler.yStack(zInd, xInd, :), [], 3)));
axis equal tight
colormap hot
caxis(clim);
title('y = 1.3mm, MAX projection')

load('\\zserver.cortexlab.net\Data\Subjects\CR015\2019-08-01\1810\2019-08-01_1810_CR015_20NPTracing.mat')
subplot(2, 2, 3)
imagesc(Doppler.xAxis(xInd), Doppler.zAxis(zInd), sqrt(min(Doppler.yStack(zInd, xInd, :), [], 3)));
axis equal tight
colormap hot
caxis(clim);
title('y = 2.0mm, MIN projection')
xlabel('x [mm]');
ylabel('z [mm]');
subplot(2, 2, 4)
imagesc(Doppler.xAxis(xInd), Doppler.zAxis(zInd), sqrt(max(Doppler.yStack(zInd, xInd, :), [], 3)));
axis equal tight
colormap hot
caxis(clim);
title('y = 2.0mm, MAX projection')
xlabel('x [mm]');

