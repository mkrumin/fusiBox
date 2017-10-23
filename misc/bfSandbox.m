% bf processing script

ExpRef = '2017-10-05_3_CR01';

fp = dat.expPath(ExpRef, 'main', 'local');
fp = fullfile(fp, 'fulldata');

doppler = getDoppler(ExpRef);

nFrames = size(doppler.frames, 3);
xx = doppler.xAxis;
zz = doppler.zAxis;
for iFrame = 5:5
    clear BF
    clear BFFilt
    filename = sprintf('%s_BF_%06.0f.mat', ExpRef, iFrame);
    fullname = fullfile(fp, filename);
    if exist(fullname, 'file')
        load(fullname)
    end
    filename = sprintf('%s_BFfilt_%06.0f.mat', ExpRef, iFrame);
    fullname = fullfile(fp, filename);
    if exist(fullname, 'file')
        load(fullname)
    end
    BF = BF{1};
    BF = permute(BF, [3 1 2]);
    [nt, nz, nx] = size(BFFilt);
    
    [b, a] = butter(4, 25/550/2, 'high');
    tic
    BF = filter(b, a, BF);
    toc
    BF = permute(BF, [2 3 1]);
    tic
    BF = rmSVD(BF, 15);
    toc
    BF = permute(BF, [3 1 2]);

    limRealBF= prctile(real(BF(:)), [1 99]);
    limImBF= prctile(imag(BF(:)), [1 99]);
    limRealBFFilt= prctile(real(BFFilt(:)), [1 99]);
    limImBFFilt= prctile(imag(BFFilt(:)), [1 99]);
    %     figure('Position', [0 0 1 1])
    for iPlane = 1:nt
        subplot(2, 2, 1)
        imagesc(xx, zz, squeeze(real(BF(iPlane, :,:))))
        caxis(limRealBF);
        title('Re(BF)');
        axis equal tight
        subplot(2, 2, 2)
        imagesc(xx, zz, squeeze(imag(BF(iPlane, :,:))))
        caxis(limImBF);
        title('Im(BF)');
        axis equal tight
        subplot(2, 2, 3)
        imagesc(xx, zz, squeeze(real(BFFilt(iPlane, :,:))))
        caxis(limRealBFFilt);
        title('Re(BFFilt)');
        axis equal tight
        subplot(2, 2, 4)
        imagesc(xx, zz, squeeze(imag(BFFilt(iPlane, :,:))))
        caxis(limImBFFilt);
        title('Re(BFFilt)');
        axis equal tight
        drawnow
        %     pause(0.01)
    end
    
end

