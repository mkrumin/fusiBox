folderNames = {'Z:\fullDataSamples\CR017\2019-11-13\3'; ...
    'Z:\fullDataSamples\CR017\2019-11-14\2';...
    'Z:\fullDataSamples\CR020\2019-11-22\2'};
ExpRefs = {'2019-11-13_3_CR017'; '2019-11-14_2_CR017'; '2019-11-22_2_CR020'};

faceMapResultsFolder = 'Z:\FaceMapResults';
fs = 500; % [Hz]
frames2skip = 5;
% binSizes = [1, 3, 5];
binSizes = 600; % 100 frames == 10 seconds of data
% maxNFrames = 100;

nSVDs = 48;
iExp = 1;
binSize = binSize(1);

ExpRef = ExpRefs{iExp};
folderName = folderNames{iExp};

tic;
fprintf('Processing, experiment %s\n', ExpRef');
files = dir(fullfile(folderName, '*mat'));
frames = frames2skip+1:length(files);
frameTimes = getFrameTimes(getTimeline(ExpRef));
binStart = tic;
fprintf('binSize = %g ms\n', binSize*100);
nBins = floor(length(frames)/binSize);
%         nFrames = min(nFrames, maxNFrames);
startFrames = (0:nBins-1) * binSize + 1;
tAxis = frameTimes(startFrames);
for iBin = 1:nBins
    fprintf('Processing bin %g/%g\n', iBin, nBins);
    fprintf('Loading data..');
    for ind = startFrames(iBin) + [0:binSize-1]
        i = ind - startFrames(iBin) + 1;
        data(i) = load(fullfile(files(frames(ind)).folder, files(frames(ind)).name));
    end
    bf = cell2mat(reshape({data(:).bf}, [], 1));
    [nT, nZ, nX] = size(bf);
    bfFlat = permute(reshape(bf, nT, nZ*nX), [2 1]);
    fprintf('.done\n');
    fprintf('Calculating SVD decomposition..');
    [U{iBin}, S{iBin}, V{iBin}] = svds(double(bfFlat), nSVDs);
    U{iBin} = single(reshape(U{iBin}, nZ, nX, nSVDs));
    S{iBin} = single(diag(S{iBin}));
    V{iBin} = single(V{iBin});
    fprintf('.done\n');
    fprintf('HP filtering and calculating SVD decomposition again..');
    [b, a] = butter(5, 50/fs*2, 'high');
    bfFlat = filter(b, a, bfFlat);
    [Uf{iBin}, Sf{iBin}, Vf{iBin}] = svds(double(bfFlat), nSVDs);
    Uf{iBin} = single(reshape(Uf{iBin}, nZ, nX, nSVDs));
    Sf{iBin} = single(diag(Sf{iBin}));
    Vf{iBin} = single(Vf{iBin});
    fprintf('.done\n');
end
fprintf('Done processing experiment %s\n', ExpRef');
toc

[animalName, expDate, expNum] = dat.parseExpRef(ExpRef);
filename = sprintf('%s_%s_faceMapResults.mat', datestr(expDate, 'yyyy-mm-dd'), animalName);
faceData = load(fullfile(faceMapResultsFolder, filename));
[~, expInd] = ismember(ExpRef, faceData.ExpRef);
faceTimes = faceData.frameTimes{expInd};
faceU = zeros(size(faceData.motionUMask));
faceU(faceData.motionUMask) = faceData.motionU(:, 3);
faceV = faceData.motionV{expInd}(:, 3);



%% plotting is done here

for iU = 1:length(U)
    tStart = tAxis(iU);
    tEnd = tStart + size(V{iU}, 1)/fs;
    faceIdx = find(faceTimes >= tStart & faceTimes < tEnd);
    plotUSVF(U{iU}, V{iU}, faceU, faceV(faceIdx), faceTimes(faceIdx));
end

%%
for iU = 1:length(Uf)
    tStart = tAxis(iU);
    tEnd = tStart + size(Vf{iU}, 1)/fs;
    faceIdx = find(faceTimes >= tStart & faceTimes < tEnd);
    plotUSVF(Uf{iU}, Vf{iU}, faceU, faceV(faceIdx), faceTimes(faceIdx));
end

%%
nU = length(U);
for iU = 1:nU
    for jU = 1:nU
        Ui = reshape(U{iU}, [], size(U{iU}, 3));
        Uj = reshape(U{jU}, [], size(U{jU}, 3));
        %         uCorr{iU, jU} = abs(Ui')*abs(Uj);
        uCorr{iU, jU} = (Ui')*(Uj);
    end
end
figure;
imagesc(abs(cell2mat(uCorr)))
axis equal tight

%%
nU = length(Uf);
for iU = 1:nU
    for jU = 1:nU
        Ui = reshape(Uf{iU}, [], size(Uf{iU}, 3));
        Uj = reshape(U{jU}, [], size(Uf{jU}, 3));
        %         uCorr{iU, jU} = abs(Ui')*abs(Uj);
        uCorr{iU, jU} = (Ui')*(Uj);
    end
end
figure;
imagesc(abs(cell2mat(uCorr)))
axis equal tight

%%
% plotUSV(U(:,:,1:24), S, V, 1/fs)
figure
imagesc(faceU)
colormap('redblue')
caxis([-1 1]*max(abs(faceU(:))))