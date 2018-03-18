load('D:\FusiAcquisitions\CR01\2018-03-01\2\fus\2018-03-01_2_CR01_fus.mat')

%%
figure
subplot(1, 2, 1)
meanImage = sqrt(mean(doppler.frames, 3));
minmax = prctile(meanImage(:), [1 99]);
imagesc(doppler.xAxis, doppler.zAxis, meanImage)
caxis(minmax);
colormap hot
axis equal tight

frames = rmSVD(doppler.frames, 1);
[nZ, nX, nFrames] = size(frames);
frames = reshape(frames, [], nFrames)';
frames = zscore(frames);

%%
for i=1:100
    [x, z, button] = ginput(1);
    if button ==3
        break;
    end
    [~, xInd] = min((doppler.xAxis-x).^2);
    [~, zInd] = min((doppler.zAxis-z).^2);
    seedIdx = sub2ind([nZ, nX], zInd, xInd);

    corrVector = frames(:, seedIdx)'*frames/nFrames;
    imCorr = reshape(corrVector, nZ, nX);
    subplot(1, 2, 2)
    imagesc(doppler.xAxis, doppler.zAxis, imCorr)
    caxis([-1 1]);
    cm = [[linspace(0, 1, 32), ones(1, 32)]', [linspace(0, 1, 32), linspace(1, 0, 32)]', [ones(1, 32), linspace(1, 0, 32)]'];
    colormap(gca, cm)
    colorbar
    axis equal tight
end


