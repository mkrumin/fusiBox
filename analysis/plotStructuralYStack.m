function plotStructuralYStack(ExpRef)

if nargin < 1
    ExpRef = '2017-12-15_2348_CR01';
%     ExpRef = '2018-01-18_1807_default';
end

%%
folder = dat.expPath(ExpRef, 'master', 'local');

load(fullfile(folder, [ExpRef, '_fUSiYStack.mat']))

nSlices = length(yCoords);
nRows = floor(sqrt(nSlices));
nColumns = ceil(nSlices/nRows);
%%
% keyboard;

%%

xx = Doppler.xAxis;
% xx = xx - 6.2;
% xIdx = abs(xx)<3.5;
xIdx = 1:length(xx);
zz = Doppler.zAxis;
% zz = zz - 1.7;
% zIdx = zz > 0;
zIdx = 1:length(zz);
data = squeeze(median(Doppler.yStack(zIdx, xIdx, :, :), 3));
data = sqrt(data);
cminmax = prctile(data(:), [0.01 99]);
for iSlice = 1:nSlices
    ax = subplot(nRows, nColumns, iSlice);
    [iColumn, iRow] = ind2sub([nColumns, nRows], iSlice);
    imagesc(xx(xIdx), zz(zIdx), (data(:, :, iSlice)));
    axis equal tight
    caxis(cminmax);
    colormap hot;
    if iRow == nRows && iColumn == 1
        xlabel('ML [mm]');
        ylabel('DV [mm]');
    else
        set(gca, 'XTickLabel', '', 'YTickLabel', '');
    end
%     title(yCoords(iSlice))
    ax.Position = ax.Position + [-0.01 -0.01 0.02 0.02];
end