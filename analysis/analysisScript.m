% analysis script

ExpRef{1} = '2017-10-05_1_CR01';
ExpRef{2} = '2017-10-05_3_CR01';
ExpRef{3} = '2017-10-05_2_CR01';

for iSlice = 1:length(ExpRef)
    res(iSlice) = analyzeKalatskyFusi(ExpRef{iSlice});
end


%%
for iSlice = 2:2%length(ExpRef)
    h(iSlice, :) = plotPreferenceMaps(res(iSlice).maps, res(iSlice).pars, 1);
    for iFig = 1:length(h(iSlice, :))
        h(iSlice, iFig).Name = res(iSlice).ExpRef;
    end
    hMean(iSlice) = plotMeanFrame(res(iSlice));
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