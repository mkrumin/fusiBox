function idx = getOutliers(mov)

meanFrame = mean(mov, 3);
stdFrame = std(mov, [], 3);
cvFrame = stdFrame./meanFrame;

[nZ, nX, nFrames] = size(mov);
mov = reshape(mov, nZ*nX, nFrames);
prcThresh = 99;
idxCV = cvFrame > prctile(cvFrame(:), prcThresh);
trace = mean(mov(idxCV, :));
thr = median(trace) + 6*mad(trace, 1);
idx = trace > thr;
