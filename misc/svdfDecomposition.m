function [svdf, fAxis, lambdas] = svdfDecomposition(data, fs)

[nt, nz, nx] = size(data);

% reshape to be nPix x nT
data = (reshape(data, nt, nx*nz)).';

[U, S, V] = svd(data, 'econ');
[nT, nS] = size(V);
% U - nP x nS matrix of spatial components
% S - nS x nS matrix of eigen values
% V - nT x nS matrix of temporal components
% resconstruction is data = U*S*V';


[svdf, fAxis] = periodogram(V, [], nT, fs);
fAxis = fftshift(fAxis);
fAxis = fAxis - fs*floor(fAxis/fs*2);
svdf = fftshift(svdf, 1);
lambdas = diag(S);

return;

%%
nS = 50;
nRows = floor(sqrt(nS));
nColumns = ceil(nS/nRows);
figure;
for iS = 1:nS
    subplot(nRows, nColumns, iS)
%     imagesc(((abs(reshape(U(:, iS), nz, nx)))));
%     imagesc(((angle(reshape(U(:, iS), nz, nx)))));
%     imagesc(((real(reshape(U(:, iS), nz, nx)))));
    imagesc(((imag(reshape(U(:, iS), nz, nx)))));
    
%     plot(xcorr(imag(V(:, iS)), 'unbiased'))
%     plot(1:nT, imag(V(:, iS)));
%     hold on;
%     plot(1:nT, real(V(:, iS)));
%     xlim([1 nT])
    
end
%%
figure;
imagesc(1:nS, fAxis, log(svdf+1))
xlabel('iSVD');
ylabel('f [Hz]');
colorbar
axis square

