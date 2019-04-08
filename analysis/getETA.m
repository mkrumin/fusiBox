function [eta, tAxis] = getETA(t, mov, eventTimes)

fprintf('Calculating getETA..')
[nZ, nX, nFrames] = size(mov);

dt = 0.05; % this is the target dt after upsampling/interpolation
tPre = 1; 
tPost = 3;
tAxis = -tPre:dt:tPost;
tAxis = tAxis(:); % make sure it is a column vector
nT = length(tAxis);

mov = reshape(mov, nZ*nX, nFrames)';
eta = nan(nT, nZ*nX);
for iT = 1:nT
    eta(iT, :) = nanmedian(interp1(t, mov, eventTimes + tAxis(iT)));
end

eta = reshape(eta', nZ, nX, nT);
fprintf('.done\n')