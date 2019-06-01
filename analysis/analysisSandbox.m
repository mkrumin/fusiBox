% analysis script

allExpRefs = cell(1);

% for iExp=1:3
%     allExpRefs{iExp} = sprintf('2018-11-16_%1.0f_CR011', iExp);
% %     allExpRefs{iExp} = sprintf('2018-11-01_%1.0f_CR011', iExp);
% end
% yPosition = [4.6 4.4 4.8];

% for iExp=[1:7, 9:12]
% %     allExpRefs{iExp} = sprintf('2018-11-16_%1.0f_CR011', iExp);
%     allExpRefs{iExp} = sprintf('2018-11-23_%1.0f_CR011', iExp);
% end

% for iExp=1:5
%     allExpRefs{iExp} = sprintf('2018-11-28_%1.0f_CR011', iExp);
% end

% for iExp=1:8
%     allExpRefs{iExp} = sprintf('2018-11-30_%1.0f_CR013_DRI2', iExp);
% end

for iExp=1:8
    allExpRefs{iExp} = sprintf('2019-02-15_%1.0f_CR_Alzheimers1', iExp+1);
end

allExpRefs = allExpRefs(~cellfun(@isempty,  allExpRefs));
yPosition = NaN(size(allExpRefs));

%% Perform the analysis for each slice independently

iExp = 6;
ExpRef = allExpRefs{iExp};
fprintf('Loading data for %s...\n', ExpRef);
t = tic;
expData = getExpData(ExpRef);
if ~isfield(expData.doppler, 'motorPosition')
    expData.doppler.motorPosition = yPosition(iExp);
end
fprintf('\t...done(%g s)\n', toc(t));

%% let's try and preprocess the movie, exclude atrefactual frames etc.

expData.idxOutliers = getOutliers(expData.doppler.frames);

%% get stim-triggered average movie

mov = expData.doppler.frames;
xIdx = expData.doppler.xAxis>=2 & expData.doppler.xAxis <=10.8;
zIdx = expData.doppler.zAxis>=0.1;
mov = mov(zIdx, xIdx, ~expData.idxOutliers);
tAxis = expData.fusiFrameTimes(~expData.idxOutliers);

I0 = prctile(mov, 50, 3);
mov = bsxfun(@minus, mov, I0);
mov = bsxfun(@rdivide, mov, I0);

% movSVD = rmSVD(mov, 100);
% mov = mov - movSVD;

staMovies = getSTA(tAxis, mov, expData);
[Fmean, Fall] = showSTAMovies(staMovies, expData);

stimCorr = getStimCorr(staMovies);
showStimCorr(stimCorr, staMovies, expData)

%%

F = createExpMovie(expData);

%% A sceleton script for full data preprocessing
% Mask the brain
YS.getMask;
YS.applyMask;
% do the preprocessing
nSVDs = 500;
fprintf('Peforming SVD decomposition (%g SVDs) ..', nSVDs);
svdTic = tic;
YS.svdDecomposition(nSVDs);
fprintf('. done (%1.0f seconds)\n', toc(svdTic));
fprintf('Rotating the dI/I SVD decomposition basis ..');
diiTic = tic;
YS.svddII(0);
fprintf('. done (%1.0f seconds)\n', toc(diiTic));
fprintf('Performing doppler registration:\n');
regTic = tic;
YS.regDoppler;
t = toc(regTic); 
h = floor(t/3600); m = floor(mod(t,3600)/60); s = floor(mod(t, 60));
fprintf('Total time spent on registration - %02.0fh%02.0fm%02.0fs\n', h, m, s)
fprintf('Detecting outlier frames ..');
outTic = tic;
YS.getOutliers(Inf);
fprintf('. done (%3.1f seconds)\n', toc(outTic));
fprintf('Processing fast doppler:\n');
fastTic = tic;
YS.processFastDoppler;
fprintf('Done processing fast doppler in %1.0f seconds', toc(fastTic));
fprintf('Calculating dII directly from doppler movies ..');
diiTic = tic;
YS.getdII;
fprintf('. done (%3.1f seconds)\n', toc(diiTic));
t = toc(svdTic); 
h = floor(t/3600); m = floor(mod(t,3600)/60); s = floor(mod(t, 60));
fprintf('Total time spent preprocessing the whole dataset - %02.0fh%02.0fm%02.0fs\n', h, m, s)

%%
% Fall = struct('cdata', [], 'colormap', []);
Fall = cell(2, 2);
nSVDs = size(YS.svd.U, 3);
Fall{1} = YS.fusi(1).movie;
Fall{2} = YS.fusi(1).movie([], 1);
Fall{3} = YS.fusi(1).movie(1:nSVDs);
Fall{4} = YS.fusi(1).movie(1:500, 1);
%%
Fall = cell(2, 2);
nSVDs = size(YS.svd.U, 3);
Fall{1} = YS.fusi(1).dIIMovie;
Fall{2} = YS.fusi(1).dIIMovie([], 1);
Fall{3} = YS.fusi(1).dIIMovie(1:nSVDs);
Fall{4} = YS.fusi(3).dIIMovie(3:30, 1);

%%
YS.plotSVDs(1:30, 1, 1)

%%
F1 = Ffull;
F2 = F500;
for iFrame=1:length(Ffull)
    F(iFrame).cdata = [Ffull(iFrame).cdata, F500(iFrame).cdata];
    F(iFrame).colormap = [];
end
%%
tic
% F = Ffull;
ExpRef = YS.fusi(1).ExpRef;
vw = VideoWriter(sprintf('%s_dII.avi', ExpRef));
vw.FrameRate = 30;
vw.Quality = 80;
open(vw);
for iFrame = 1:length(Fall{1})
    fprintf('Frame %d/%d\n', iFrame, length(Fall{1}))
    writeVideo(vw, [Fall{1}(iFrame).cdata, Fall{3}(iFrame).cdata; Fall{2}(iFrame).cdata, Fall{4}(iFrame).cdata]); 
end
close(vw)
toc

%%
tic
nameLeft = '2019-05-15_1_PC041.avi';
nameRight = '2019-05-15_1_PC041_dII.avi';
vrLeft = VideoReader(nameLeft);
nFrames = vrLeft.NumberOfFrames;
vrLeft = VideoReader(nameLeft);
vrRight = VideoReader(nameRight);

ExpRef = '2019-05-15_1_PC041';
vw = VideoWriter(sprintf('%s_AllSmall.avi', ExpRef));
vw.FrameRate = 30;
vw.Quality = 70;
open(vw);
for iFrame = 1:nFrames
    fprintf('Frame %d/%d\n', iFrame, nFrames)
    frLeft = readFrame(vrLeft);
    frRight = readFrame(vrRight);
    writeVideo(vw, imresize([frLeft, frRight], 0.5)); 
end
close(vw)
toc



