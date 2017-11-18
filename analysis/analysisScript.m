% analysis script

ExpRef = cell(1);

% ExpRef{1} = '2017-10-05_1_CR01';
% ExpRef{2} = '2017-10-05_3_CR01';
% ExpRef{3} = '2017-10-05_2_CR01';

% ExpRef{1} = '2017-11-10_1_CR07';
% ExpRef{2} = '2017-11-10_3_CR07';

% ExpRef{1} = '2017-11-13_1_CR01';

% ExpRef{1} = '2017-11-15_5_CR07';

% y-stack experiment
for iExp=1:13
    ExpRef{iExp} = sprintf('2017-11-17_%1.0f_CR01', iExp+1);
end
yPosition = [0 1 2 3 4 0.33 1.33 2.33 3.33 0.67 1.67 2.67 3.67];
%%

for iSlice = 1:length(ExpRef)
    res(iSlice) = analyzeKalatskyFusi(ExpRef{iSlice});
end

%%

h = plotYStack(res, yPosition);

%%
for iSlice = 1:length(ExpRef)
    h(iSlice, :) = plotPreferenceMaps(res(iSlice).maps, res(iSlice).pars, 1);
    for iFig = 1:length(h(iSlice, :))
        h(iSlice, iFig).Name = res(iSlice).ExpRef;
    end
    hMean(iSlice) = plotMeanFrame(res(iSlice));
end

%% 
function h = plotYStack(res, yy)

nSlices = length(res);
[ySorted, ySortedIdx] = sort(yy, 'ascend');
res = res(ySortedIdx);
meanStack = reshape({res.meanFrame}, 1, 1, nSlices);
meanStack = cell2mat(meanStack);

% trim the stack and the axes now
xAxis = res(1).pars(1).xAxis;
xIdx = find(xAxis>=3 & xAxis <=10);
yAxis = res(1).pars(1).yAxis;
yIdx = find(yAxis>=2);
meanStack = meanStack(yIdx, xIdx, :);
xAxis = xAxis(xIdx);
yAxis = yAxis(yIdx);


meanStack = meanStack - min(meanStack(:));
meanStack = meanStack/max(meanStack(:));

meanStack = permute(meanStack, [3 2 1]);
meanStack = flip(meanStack, 3);

[Xold, Yold, Zold] = meshgrid(xAxis, ySorted, yAxis);
yInterpolated = 0:0.1:4;
[X, Y, Z] = meshgrid(xAxis, yInterpolated, yAxis);
meanStack = interp3(Xold, Yold, Zold, meanStack, X, Y, Z);

% h = slice(-meanStack, [], [1:13], []);
% h = slice(X, Y, Z, -meanStack, [], [ySorted], [], 'linear');
h = slice(X, Y, Z, -meanStack, [], yInterpolated, [], 'linear');
xlabel('x')
ylabel('y');
zlabel('z')
caxis(prctile(-meanStack(:), [1 99]));
colormap gray
colorbar
for i = 1:length(h)
    h(i).LineStyle = 'none';
    h(i).FaceAlpha = 'flat';
    h(i).AlphaData = squeeze(meanStack(i, :, :).^1);
end
axis equal tight



end
%%
function h = plotMeanFrame(data)

h = figure('Name', data.ExpRef);
im = -data.meanFrame;
imagesc(data.pars(1).xAxis, data.pars(1).yAxis, im);
colormap gray
axis equal tight
caxis(prctile(im(:), [1 99]));
xlabel('X [mm]')
ylabel('Depth [mm]');
title('Average frame');

end