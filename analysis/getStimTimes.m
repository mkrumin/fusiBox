function [stimTimes, frameTimes] = getStimTimes(TL, p)

% stimTimes is a nStims x nRepeats cell array 
% stimTimes{iStim, iRepeat}(1) - is the onset of stimulus iStim on repeat iRepeat
% stimTimes{iStim, iRepeat}(2) - is the offset of ...
% TL - Timeline structure
% p - Protocol structure, as saved by mpep


% getting UDP times from the Timeline structure
udpStartTimes = getUDPTimes(TL, 'StimStart');
udpEndTimes = getUDPTimes(TL, 'StimEnd');

phdTimes = getPhdTimes(TL, udpStartTimes, udpEndTimes);

nStims = length(phdTimes);
stimStartTimes = nan(nStims, 1);
stimEndTimes = nan(nStims, 1);
frameTimes = cell(nStims, 1);
for iStim = 1:nStims
    stimStartTimes(iStim) = phdTimes(iStim).up(1);
    stimEndTimes(iStim) = phdTimes(iStim).down(end);
    frameTimes{iStim} = sort([phdTimes(iStim).up(:); phdTimes(iStim).down(:)], 'ascend');
end

% parsing the protocol data - unrandomizing the sequence
[nStims, nRepeats] = size(p.seqnums);
if (length(frameTimes) < nStims * nRepeats)
    % if the mpep experiment was aborted without finishing all repeats
    nRepeats = length(frameTimes)/nStims;
    p.seqnums = p.seqnums(1:nStims, 1:nRepeats);
end

stimTimes = cat(1, stimStartTimes(p.seqnums), stimEndTimes(p.seqnums));
stimTimes = reshape(stimTimes, nStims, nRepeats*2);
stimTimes = mat2cell(stimTimes, ones(nStims, 1), 2*ones(nRepeats, 1));

frameTimes = frameTimes(p.seqnums);
frameTimes = reshape(frameTimes, nStims, nRepeats);
