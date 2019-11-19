% analysis script

ExpRef = cell(1);

% ExpRef{1} = '2017-10-05_1_CR01';
% ExpRef{2} = '2017-10-05_3_CR01';
% ExpRef{3} = '2017-10-05_2_CR01';

% ExpRef{1} = '2017-11-10_1_CR07';
% ExpRef{2} = '2017-11-10_3_CR07';

% ExpRef{1} = '2017-11-13_1_CR01';

% ExpRef{1} = '2017-11-15_5_CR07';

ExpRef{1} = '2018-03-01_1_CR01';

ExpRef{1} = '2018-03-19_2_CR01';

% y-stack experiment
for iExp=1:13
    ExpRef{iExp} = sprintf('2017-11-17_%1.0f_CR01', iExp+1);
end
yPosition = [0 1 2 3 4 0.33 1.33 2.33 3.33 0.67 1.67 2.67 3.67];
%%
ExpRef = {'2019-11-15_1_CR020'};
yPosition = [0.4, 0.6]; 

nSlices = length(ExpRef);
for iSlice = 1:nSlices
    fprintf('Analyzing slice %d/%d\n', iSlice, nSlices);
    res(iSlice) = analyzeKalatskyFusi(ExpRef{iSlice});
end

res(2) = res(1);
%%

ax = plotYStack(res, yPosition);

%% make a movie

linkprop(ax, {'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
hFig = ax(1).Parent;

nCycles = 8;
azStart = -30;
az = [0:2:360*nCycles] + azStart;
elBias = 20;
elStart = 20;
elAmp = 40;
el = elAmp*cos((az-azStart)/180*pi/nCycles - acos(elStart-elBias)) + elBias;

tic
vw = VideoWriter('2017-11-17_CR01_Retinotopy_smoothed.avi');
vw.FrameRate = 30;
vw.Quality = 90;
open(vw);
for iFrame = 1:length(az)
    fprintf('Frame %d/%d\n', iFrame, length(az))
    view(ax(1), az(iFrame), el(iFrame));  
    drawnow;
    frame = getframe(hFig, [180 0 1640 720]);
    writeVideo(vw, frame.cdata); 
end
close(vw)
toc
sendEmail('michael@cortexlab.net', 'rendering done');
%%
for iSlice = 1:length(ExpRef)
    h(iSlice, :) = plotPreferenceMaps(res(iSlice).maps, res(iSlice).pars, 1);
    for iFig = 1:length(h(iSlice, :))
        h(iSlice, iFig).Name = res(iSlice).ExpRef;
    end
    hMean(iSlice) = plotMeanFrame(res(iSlice));
end

%% 
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