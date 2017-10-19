function stimTimes = getStimTimes(TL, p)

% stimTimes is a nStims x nRepeats cell array 
% stimTimes{iStim, iRepeat}(1) - is the onset of stimulus iStim on repeat iRepeat
% stimTimes{iStim, iRepeat}(2) - is the offset of ...
% TL - Timeline structure
% p - Protocol structure, as saved by mpep


% getting UDP times from the Timeline structure
udpStartTimes = getUDPTimes(TL, 'StimStart');
udpEndTimes = getUDPTimes(TL, 'StimEnd');

phdTimes = getPhdTimes(TL);

idx = cellfun(@(x) find(phdTimes.up>x , 1, 'first'), num2cell(udpStartTimes));
stimStartTimes = phdTimes.up(idx)';

idx = cellfun(@(x) find(phdTimes.down<x , 1, 'last'), num2cell(udpEndTimes));
stimEndTimes = phdTimes.down(idx)';

% parsing the protocol data - unrandomizing the sequence
[nStims, nRepeats] = size(p.seqnums);

stimTimes = cat(1, stimStartTimes(p.seqnums), stimEndTimes(p.seqnums));
stimTimes = reshape(stimTimes, nStims, nRepeats*2);
stimTimes = mat2cell(stimTimes, ones(nStims, 1), 2*ones(nRepeats, 1));