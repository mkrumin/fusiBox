function movOut = rmSVD(movIn, nSVDs)

if nSVDs == 0
    % do nothing, return the original movie
    movOut = movIn;
    return;
else
    % calculate the first nSVDs SVDs and subtract them from the movie
    [nz, nx, nt] = size(movIn);
    movIn = reshape(movIn, [], nt);
    [U, S, V] = svds(double(movIn), nSVDs);
    movOut = single(movIn - U*S*V');
    movOut = reshape(movOut, nz, nx, nt);
end
