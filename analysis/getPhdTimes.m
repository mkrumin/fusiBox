function phdTimes = getPhdTimes(TL, stimStartTimes, stimEndTimes)


phdTimes = struct('up',[], 'down', []);

% find the channel index of the photodiode
iCh = find(ismember({TL.hw.inputs.name}, 'photoDiode'));
iChEcho = find(ismember({TL.hw.inputs.name}, 'syncEcho'));

phd = TL.rawDAQData(:, iCh); % raw photodiode signal
fs = 1/TL.hw.samplingInterval; % sampling rate

%%

if ~isempty(iChEcho)
    % if syncEcho signal exists use it (it is more reliable)
    syncEcho = TL.rawDAQData(:, iChEcho); % syncEcho Channel
    maxlag = round(fs);
    xc = xcorr(phd, syncEcho, maxlag, 'biased');
    [~, idxMax] = max(xc);
    idxMax = idxMax - maxlag;
    phdFilt = zeros(size(phd));
    if idxMax>0
        phdFilt(idxMax+1:end) = syncEcho(1:end-idxMax);
    else
        idxMax = -idxMax;
        phdFilt(1:end-idxMax) = syncEcho(idxMax+1:end);
    end
    phdFilt = phdFilt - min(phdFilt) - (max(phdFilt)-min(phdFilt))/2;
else
    % otherwise use the actual photodiode signal
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
end

%%
thresh = 0;
phdAbove = phdFilt>thresh;
phdTransitions = [0; diff(phdAbove)];
allUps = TL.rawDAQTimestamps((phdTransitions == 1));
allDowns = TL.rawDAQTimestamps((phdTransitions == -1));
allUps = allUps(:);
allDowns = allDowns(:);

if ~isempty(iChEcho)
    % use the same syncEcho signal here as well
    rawTransitions = phdTransitions;
else
    rawTransitions = [0; diff((phd - mean(phd))>thresh)];
end
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
    phdTimes(iStim).up = allUps(firstUpInd:lastUpInd);
    phdTimes(iStim).down = allDowns(firstDownInd:lastDownInd);
end

phdTimes = phdTimes(:);

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

