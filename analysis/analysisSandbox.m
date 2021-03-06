% analysis script

dataFolder = 'F:\fUSiData';
allExpRefs = {...
    '2019-04-02_1716_PC036'; ...
    '2019-04-04_2133_PC036'; ...
    '2019-04-08_2359_PC036'; ...
    '2019-04-09_2359_PC036'; ...
    '2019-04-10_2327_PC036'; ...
    '2019-04-12_2124_PC036'; ...
    '2019-04-15_2306_PC036'; ...
    '2019-05-03_1757_PC036'; ...
    '2019-04-11_2349_PC037'; ...
    '2019-04-12_2359_PC037'; ...
    '2019-04-16_2117_PC037'; ...
    '2019-05-07_2105_PC037'; ...
    '2019-05-08_2042_PC037'; ...
    '2019-05-10_1912_PC037'; ...
    '2019-05-13_1753_PC037'; ...
    '2019-05-15_1759_PC037'; ...
    '2019-05-16_1434_PC037'; ...
    '2019-05-17_1853_PC037'; ...
    '2019-05-20_1436_PC037'; ...
    '2019-05-21_1435_PC037'; ...
    '2019-05-22_1518_PC037'; ...
    '2019-05-24_1328_PC037'; ...
    '2019-05-28_1826_PC037'; ...
    '2019-05-29_1357_PC037'; ...
    '2019-05-14_2317_PC041'; ...
%     '2019-05-15_2302_PC041'; ...
    '2019-05-16_1733_PC041'; ...
    '2019-05-17_2255_PC041'; ...
    '2019-05-20_1719_PC041'; ...
    '2019-05-21_1926_PC041'; ...
    '2019-05-22_2327_PC041'; ...
    '2019-05-23_1934_PC041'; ...
    '2019-05-24_1853_PC041'; ...
    '2019-05-28_2146_PC041'; ...
    '2019-05-29_1907_PC041'; ...
    '2019-05-30_2130_PC041'; ...
    '2019-05-31_1953_PC041'; ...    
    };

%% This is the manual stage of adjusting the mask

% load the dataset
% first 13 datasets have no unreg data saved (up to and including
% 2019-05-08_2042_PC037)
iExp = 37;
ExpRef = allExpRefs{iExp};
[animalName, expDate, expNumber] = dat.parseExpRef(ExpRef);
fileName = [ExpRef, '_YS.mat'];
fileNameMask = [ExpRef, '_YSMask.mat'];
folderName = fullfile(dataFolder, animalName);

% do the following steps iteratively until happy with the mask
load(fullfile(folderName, fileName));

% YS.mask.poly = poly; % do this if only adjusting a mask
YS.fusi(1).movie;
YS.getMask; 
poly = YS.mask.poly;
YS.applyMask;
YS.fusi(1).movie;

% when happy with the mask, save it
% this file will be used later for full data processing
% remove Timeline data, it takes too much unnecessary space
for iFus = 1:length(YS.fusi)
    YS.fusi(iFus).TL = [];
end
% save the light version (no doppler data) of the YStack
YS.saveLite(fullfile(folderName, fileNameMask));
close all;

%% After we have the masks, we can run the following code automatically
dataFolder = 'F:\fUSiData\';
for iExp = 1:length(allExpRefs)
    ExpRef = allExpRefs{iExp};
    fprintf('\nProcessing dataset %s:\n', ExpRef);
    expTic = tic;
    animalName = dat.parseExpRef(ExpRef);
    dataFile = fullfile(dataFolder, animalName, [ExpRef, '_YS.mat']);
    maskFile = fullfile(dataFolder, animalName, [ExpRef, '_YSMask.mat']);
    saveFile = fullfile(dataFolder, animalName, [ExpRef, '_YSLite.mat']);
%     if ~(exist(dataFile, 'file') && exist(maskFile, 'file'))
%         warning('Some files are missing for %s\n', ExpRef);
%     end
    preprocessYS(dataFile, saveFile, maskFile);
    t = toc(expTic);
    h = floor(t/3600); m = floor(mod(t,3600)/60); s = floor(mod(t, 60));
    fprintf('\nTotal time taken to process %s : %02.0fh%02.0fm%02.0fs\n', ...
        ExpRef, h, m, s);
end
    
%% A skeleton script for full data preprocessing
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
fprintf('Done processing fast doppler in %1.0f seconds\n', toc(fastTic));
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
tic
% F = Ffull;
ExpRef = YSLite.fusi(1).ExpRef;
vw = VideoWriter(sprintf('%s_nonRegReg', ExpRef), 'MPEG-4');
vw.FrameRate = 15;
vw.Quality = 70;
open(vw);
% vr = VideoReader('2019-05-15_1_PC041_dII.avi');

for iFrame = 1:1000
    fprintf('Frame %d/%d\n', iFrame, length(F))
    frame = [Fleft(iFrame).cdata, F(iFrame).cdata];
    writeVideo(vw, frame);
%     writeVideo(vw, [Fall{1}(iFrame).cdata, Fall{3}(iFrame).cdata; Fall{2}(iFrame).cdata, Fall{4}(iFrame).cdata]); 
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

%%
