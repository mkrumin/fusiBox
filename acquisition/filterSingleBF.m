function frameOut = filterSingleBF(bf, Wn, nSVDs)

if nargin < 2 || isempty(Wn)
    Wn = 15/250; % 15 Hz assuming 500 Hz sampling frequency
end
if nargin < 2 || isempty(Wn)
    [nT, nZ, nX] = size(bf);
    nSVDs = round(nT/10); % assuming the setting of 0.1 of the nSVD in SCAN 
end

[b, a] = butter(3, Wn, 'high');

bfFilt = single(filtfilt(b, a, double(bf)));
% bfFilt = filtfilt(b, a, real(bf)) + 1i * filtfilt(b, a, imag(bf));
bfFilt = shiftdim(bfFilt, 1);
bfSvd = rmSVD(bfFilt, nSVDs);
frameOut = mean(bfSvd.*conj(bfSvd), 3);