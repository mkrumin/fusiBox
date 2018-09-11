% analysis script

ExpRef = cell(1);

% as an example: the best y-stack retinotopy experiment so far
for iExp=1:13
    ExpRef{iExp} = sprintf('2017-11-17_%1.0f_CR01', iExp+1);
end
yPosition = [0 1 2 3 4 0.33 1.33 2.33 3.33 0.67 1.67 2.67 3.67];
%% Perform Kalatsky stimulus analysis for each slice independently

nSlices = length(ExpRef);
for iSlice = 1:nSlices
    fprintf('Analyzing slice %d/%d\n', iSlice, nSlices);
    res(iSlice) = analyzeKalatskyFusi(ExpRef{iSlice});
end

%% Plot results
for iSlice = 1:length(ExpRef)
    h(iSlice, :) = plotPreferenceMaps(res(iSlice).maps, res(iSlice).pars, 1);
    for iFig = 1:length(h(iSlice, :))
        h(iSlice, iFig).Name = res(iSlice).ExpRef;
    end
    hMean(iSlice) = plotMeanFrame(res(iSlice));
end

%% supplementary functions
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