function res = saveFacemapResults(p)

% p - output of the MovieGUI (called proc by Carsen)
% res - output structure with following fields
%            nFiles: number of files processed
%        animalName: animal name (guess form one of the file names)
%        expDateStr: experiment date string, e.g. '2019-11-13'
%            ExpRef: nExps x 1 cell array of ExpRefs
%        frameTimes: nExps x 1 cell array with Timeline-aligned timestamps 
%                    of video frames, each cell is a nFrames x 1 vector 
%                    of timestamps
%         meanFrame: nY x nX matrix (float single)
%        meanMotion: nY x nX matrix with average 'motion energy'
%             nSVDs: nSVDs calculated for motion analysis across all ROIs
%       motionUMask: nY x nX bool matrix (true - pixels used in motion analysis) 
%           motionU: nPixels x nSVDs float single with spatial SVD components 
%                    of the global ROI
%     motionAvgFlat: nPixels x 1 float single 'average motion' of the
%                    global ROI
%         motionAvg: nY x nX float double with 'average motion' of global ROI
%           motionV: nExps x 1 cell array with temporal SVD components,
%                    each cell is nFrames x nSVDs float single vector
%         localROIs: 1 x nROIs structure array with the results for small
%                    local ROIs. Each structure has the same data as all
%                    the motionXXX variables above, but for local ROIs
%            pupilX: nExps x 1 cell array each nFrames x 1 float single vector 
%                    with pupil X position
%            pupilY: nExps x 1 cell array each nFrames x 1 float single vector 
%                    with pupil Y position
%         pupilArea: nExps x 1 cell array each nFrames x 1 float single vector 
%                    with pupil area
%         blinkArea: nExps x 1 cell array each nFrames x 1 float single vector 
%                    with a number of saturated pixels in blink ROI -
%                    related to blinks (might be that low values == blink)

%% for the whole batch
nSVDs = 100; % we don;t need all 500 of them
nSVDs = min(nSVDs, size(p.uMotMask{1}, 2));
res.nFiles = length(p.files);
[folderName, fileName, ~] = fileparts(p.files{1});
tmp = split(fileName, '_');
res.animalName = tmp{3};
res.expDateStr = tmp{1};

expNum = nan(res.nFiles, 1);
ExpRef = cell(res.nFiles, 1);
frameTimes = cell(res.nFiles, 1);
for iFile = 1:res.nFiles
    [folderName, fileName, ~] = fileparts(p.files{iFile});
    tmp = split(fileName, '_');
    ExpRef{iFile} = sprintf('%s_%s_%s', tmp{1}, tmp{2}, tmp{3});
    expNum(iFile) = str2num(tmp{2});
    frameTimes{iFile} = et.getFrameTimes(ExpRef{iFile});
end
[~, sortedOrder] = sort(expNum);

res.ExpRef = ExpRef(sortedOrder);
res.frameTimes = frameTimes(sortedOrder);
res.meanFrame = reshape(p.avgframe, size(p.wpix{1}));
res.meanMotion = reshape(p.avgmotion, size(p.wpix{1}));
res.nSVDs = nSVDs;

%%
% processing the large ROI
res.motionUMask = p.wpix{1};
res.motionU = p.uMotMask{1}(:, 1:nSVDs);
res.motionAvgFlat = p.avgmot{1};
res.motionAvg = nan(size(res.motionUMask));
res.motionAvg(res.motionUMask) = res.motionAvgFlat;
res.motionV = mat2cell(p.motSVD{1}(:, 1:nSVDs), p.nframes, nSVDs);
res.motionV = res.motionV(sortedOrder);

% processing all local ROIs
for i = 2:length(p.motSVD)
    local(i-1).motionUMask = false(size(p.wpix{1}));
    pos = round(p.locROI{i});
    local(i-1).motionUMask(pos(2):pos(2) + pos(4)-1, pos(1):pos(1) + pos(3)-1) = true;
    local(i-1).motionU = reshape(p.uMotMask{i}(:, :, 1:nSVDs), [], nSVDs);
    local(i-1).motionAvgFlat = p.avgmot{i};
    local(i-1).motionAvg = nan(size(local(i-1).motionUMask));
    local(i-1).motionAvg(local(i-1).motionUMask) = local(i-1).motionAvgFlat;
    local(i-1).motionV = mat2cell(p.motSVD{i}(:, 1:nSVDs), p.nframes, nSVDs);
    local(i-1).motionV = local(i-1).motionV(sortedOrder);
end

res.localROIs = local;

% eye tracking data
pupilX = mat2cell(p.pupil(1).com(:,1), p.nframes, 1);
pupilY = mat2cell(p.pupil(1).com(:,2), p.nframes, 1);
pupilArea = mat2cell(p.pupil(1).area, p.nframes, 1);
blinkArea = mat2cell(p.blink.area, p.nframes, 1);

res.pupilX = pupilX(sortedOrder);
res.pupilY = pupilY(sortedOrder);
res.pupilArea = pupilArea(sortedOrder);
res.blinkArea = blinkArea(sortedOrder);

% return;
%% 
filename = fullfile(p.rootfolder, sprintf('%s_%s_faceMapResults.mat', res.expDateStr, res.animalName));
save(filename, '-struct', 'res', '-v7.3', '-nocompression')
