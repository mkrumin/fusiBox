% function alignSliceWithStack(stackRef, sliceRef)
% 
% if nargin<1
    stackRef = '2018-11-23_2215_CR011';
    sliceRef = '2018-11-23_1_CR011';
% end

stackFile = [stackRef, '_fUSiYStack.mat'];
try
    stackFolder = dat.expPath(stackRef, 'main', 'local');
    stackData = load(fullfile(stackFolder, stackFile));
catch
    stackFolder = dat.expPath(stackRef, 'main', 'master');
    stackData = load(fullfile(stackFolder, stackFile));
end

sliceFile = [sliceRef, '_fus.mat'];
try
    sliceFolder = dat.expPath(sliceRef, 'main', 'local');
    sliceData = load(fullfile(sliceFolder, sliceFile));
catch
    sliceFolder = dat.expPath(sliceRef, 'main', 'master');
    sliceData = load(fullfile(sliceFolder, sliceFile));
end

%%
meanSlice = median(sliceData.doppler.frames, 3);
xx = sliceData.doppler.xAxis;
zz = sliceData.doppler.zAxis;

meanStack = squeeze(median(stackData.Doppler.yStack, 3));
xx = stackData.Doppler.xAxis;
zz = stackData.Doppler.zAxis;


%%
nSlices = size(meanStack, 3);
rho = nan(nSlices, 1);
for iSlice = 1:nSlices
    tmp = corrcoef(meanSlice, meanStack(:,:,iSlice));
%     tmp = corrcoef(sqrt(meanSlice), sqrt(meanStack(:,:,iSlice)));
%     tmp = corrcoef(log(meanSlice), log(meanStack(:,:,iSlice)));
    rho(iSlice) = tmp(2);
end

[~, iMax] = max(rho);
yMax = stackData.yCoords(iMax);

figure
subplot(2, 1, 1);
plot(stackData.yCoords, rho, '.-')
subplot(2, 2, 3)
imagesc(xx, zz, log(meanSlice))
axis equal tight
subplot(2, 2, 4)
imagesc(xx, zz, log(meanStack(:,:,iMax)))
title(yMax);
axis equal tight
