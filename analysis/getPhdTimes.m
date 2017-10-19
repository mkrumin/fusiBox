function phdTimes = getPhdTimes(TL)

phdTimes.up = [];
phdTimes.down = [];

% find the channel index of the photodiode
iCh = find(ismember({TL.hw.inputs.name}, 'photoDiode'));

phd = TL.rawDAQData(:, iCh); % raw photodiode signal
fs = 1/TL.hw.samplingInterval; % sampling rate

% We want to remove very high frequencies
N = round(fs/5); % 0.4 second long with filtfilt
cutoff = 250; % [Hz]
wn = cutoff/(fs/2);
[b, a] = fir1(N, wn, 'low');
phdFilt = filtfilt(b, a, phd);
% a simple median(5) filter might work as well, to remove salt-and-pepper noise

phdMax = max(phdFilt(:));
phdMin = min(phdFilt(:));
thresh = (phdMax + phdMin)/2;
phdAbove = phdFilt>thresh;
phdTransitions = [0; diff(phdAbove)];
phdTimes.up = TL.rawDAQTimestamps((phdTransitions == 1));
phdTimes.down = TL.rawDAQTimestamps((phdTransitions == -1));
% find sample indices where increments occur 
% (this is a simple edge counter channel)

