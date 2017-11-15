function phdTimes = getPhdTimes(TL, stimStartTimes, stimEndTimes)

phdTimes.up = [];
phdTimes.down = [];

% find the channel index of the photodiode
iCh = find(ismember({TL.hw.inputs.name}, 'photoDiode'));

phd = TL.rawDAQData(:, iCh); % raw photodiode signal
fs = 1/TL.hw.samplingInterval; % sampling rate

%%
% We want to remove very high frequencies, and also treat some other
% artefacts
N = round(fs/5); % 0.2 second long with filtfilt
cutoff = [24 48]; % [Hz] % these were hand-picked to suit example datasets
% the idea is that you want to keep 30 Hz, and these parameters worked well
% on various 'artefacts' (e.g. phd riding on top of slow steps wave) 
% in these datasets
wn = cutoff/(fs/2);
[b, a] = fir1(N, wn, 'band');
phdFilt = filtfilt(b, a, phd);

%%
thresh = 0;
phdAbove = phdFilt>thresh;
phdTransitions = [0; diff(phdAbove)];
allUps = TL.rawDAQTimestamps((phdTransitions == 1));
allDowns = TL.rawDAQTimestamps((phdTransitions == -1));
allUps = allUps(:);
allDowns = allDowns(:);

rawTransitions = [0; diff((phd - mean(phd))>thresh)];
rawUps = TL.rawDAQTimestamps((rawTransitions == 1));
rawDowns = TL.rawDAQTimestamps((rawTransitions == -1));

nStims = length(stimStartTimes);
for iStim = 1:nStims
    firstUp = find(rawUps > stimStartTimes(iStim), 1, 'first');
    % allowing extra 16ms, which might be necessary due to filtering
    firstUpT = rawUps(firstUp)-0.016;
    lastDown = find(rawDowns < stimEndTimes(iStim), 1, 'last');
    lastDownT = rawDowns(lastDown)+0.016;

    firstUpInd = find(allUps > firstUpT, 1, 'first');
    lastDownInd = find(allDowns < lastDownT, 1, 'last');
    % make sure the last up is BEFORE the last down
    lastUpInd = find(allUps < allDowns(lastDownInd), 1, 'last');
    % make sure the first down is AFTER the first up
    firstDownInd = find(allDowns > allUps(firstUpInd), 1, 'first');
    phdTimes.up = cat(1, phdTimes.up, allUps(firstUpInd:lastUpInd));
    phdTimes.down = cat(1, phdTimes.down, allDowns(firstDownInd:lastDownInd));
end

return;
%%
figure;
plot(TL.rawDAQTimestamps, phdFilt); 
hold on; 
plot(xlim, [0 0], 'r:'); 
plot(TL.rawDAQTimestamps, phd-mean(phd))
stem(phdTimes.up, ones(size(phdTimes.up)), 'g')
stem(phdTimes.down, ones(size(phdTimes.down)), 'r');
stem(stimStartTimes, ones(size(stimStartTimes)), 'c');
stem(stimEndTimes, ones(size(stimEndTimes)), 'm');
title(sprintf('wn = [%d %d], N = %d', cutoff(1), cutoff(2), N))

