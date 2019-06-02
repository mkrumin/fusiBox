function [U, S, V] = nanSVD(mov, nSVDs)

% this function will first remove the NaNs from the data, then do SVD
% decomposition and then put the NaNs back.
% should be more efficient then just zeroing the NaNs

[nz, nx, nt] = size(mov);
dataType = class(mov);
mov = reshape(mov, nz*nx, nt);
nanIdx = any(isnan(mov), 2);
% removing the NaN pixels to reduce array size for SVD
mov = double(mov(~nanIdx, :));
[Utmp, S, V] = svds(mov, nSVDs);
% introducing back the NaN pixels
U = nan(nz * nx, nSVDs);
U(~nanIdx, :) = Utmp;

% return the original data type
U = cast(U, dataType);
S = cast(S, dataType);
V = cast(V, dataType);
