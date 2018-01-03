function plotStructuralYStack(ExpRef)

if nargin < 1
    ExpRef = '2017-12-15_2348_CR01';
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
xx = xx - 6.2;
xIdx = abs(xx)<3.5;
zz = Doppler.zAxis;
zz = zz - 1.7;
zIdx = zz > 0;
data = squeeze(mean(Doppler.yStack(zIdx, xIdx, :, :), 3));
% data = log(data);
cminmax = prctile(data(:), [0.01 98]);
for iSlice = 1:nSlices
    ax = subplot(nRows, nColumns, iSlice);
    [iColumn, iRow] = ind2sub([nColumns, nRows], iSlice);
    imagesc(xx(xIdx), zz(zIdx), data(:, :, iSlice));
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