function acquireYStack(mouseName, yCoords, S, M)

% mouseName - mouse name
% yCoords - coordinates of slices to acquire
% S - SCAN object to control the fUSi acquisition
% M - motor object to control the movement

Nimg = 30;
NimgBM = 1;
dt = 0.5; % probably unnecessary
quality = 'LQ';

nY = length(yCoords);

[xAxisDop, zAxisDop] = S.getAxis(['D', quality]);
yStackDoppler = nan(numel(zAxisDop), numel(xAxisDop), Nimg, nY, 'single');
[xAxisBM, zAxisBM] = S.getAxis('BM');
yStackBMode = nan(numel(zAxisBM), numel(xAxisBM), NimgBM, nY, 'single');

hFig = figure;
nRows = floor(sqrt(nY));
nColumns = ceil(nY/nRows);

tStart = tic;
for iY = 1:nY
    tSlice = tic;
    fprintf('Slice %d/%d\n', iY, nY);
    fprintf('Moving to y = %4.2f [mm]\n', yCoords(iY));
    M.moveA(yCoords(iY));
    % allow the vibrations to settle - 1 sec shoud be safe
    pause(1);
    fprintf('Acquiring %d frames of B-Mode\n', NimgBM);
    for iN = 1:NimgBM
        S.Bmode(1);
        yStackBMode(:,:,iN,iY) = S.I0;
    end
    fprintf('Acquiring %d frames of Doppler\n', Nimg);
%     I0 = S.FilmDoppler(Nimg, dt, quality);
    S.FilmFast(Nimg);
    yStackDoppler(:,:,:,iY) = S.I1;
    figure(hFig);
    subplot(nRows, nColumns, iY);
    im = sqrt(mean(yStackDoppler(:,:,:,iY), 3));
    imagesc(xAxisDop, zAxisDop, im);
    caxis(prctile(im(:), [1 99.7]));
    colormap hot;
    axis equal tight
    title(sprintf('y = %4.2f', yCoords(iY)));
    fprintf('Slice %d/%d done in %4.2f s, total %4.2f s\n', iY, nY, toc(tSlice), toc(tStart));
end

data.params = getParameters(S);
data.yCoords = yCoords;
data.Doppler.yStack = yStackDoppler;
data.Doppler.xAxis = xAxisDop;
data.Doppler.zAxis = zAxisDop;
data.BMode.yStack = yStackBMode;
data.BMode.xAxis = xAxisBM;
data.BMode.zAxis = zAxisBM;

ExpRef = sprintf('%s_%s_%s', datestr(now, 'yyyy-mm-dd'), datestr(now, 'HHMM'), mouseName);
filename = [ExpRef, '_fUSiYStack.mat'];
folder = dat.expPath(ExpRef, 'main', 'local');

fprintf('Saving data to %s..', fullfile(folder, filename));

if ~exist(folder, 'dir')
    mkdir(folder);
end

save(fullfile(folder, filename), '-struct', 'data')

fprintf('.done\n');