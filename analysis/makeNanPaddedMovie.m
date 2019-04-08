function [tOut, movOut] = makeNanPaddedMovie(t, movIn, frameDuration)

t = t(:)';
t2 = t+frameDuration; % end of frame time
t3 = (t+frameDuration + [t(2:end), NaN])/2; % time of the middle of the gap inbetween the frames
t = [t; t2; t3];
tOut = t(:);
tOut = tOut(1:end - 1);

[nZ, nX, nT] = size(movIn);
movOut = repmat(reshape(movIn, nZ, nX, 1, nT), 1, 1, 3, 1);
movOut(:,:,3, :) = NaN;
movOut = reshape(movOut, nZ, nX, 3*nT);
movOut = movOut(:,:,1:end-1);
