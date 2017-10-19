function pars = getStimPars(p)

nStims = size(p.pars, 2);
pars = struct;
indDur = find(ismember(p.parnames, 'dur'));
indTf = find(ismember(p.parnames, 'tf'));
indOri = find(ismember(p.parnames, 'ori'));
indStart = find(ismember(p.parnames, 'start'));
indEnd = find(ismember(p.parnames, 'end'));
indDir = find(ismember(p.parnames, 'dir'));
for iStim = 1:nStims
    pars(iStim).duration = p.pars(indDur, iStim)/10; % [sec]
    pars(iStim).nCycles = round(pars(iStim).duration*p.pars(indTf, iStim)/100); % n per stimulus
    pars(iStim).cycleDuration = 100/p.pars(indTf, iStim); % [sec]
    if p.pars(indOri, iStim) == 1
        pars(iStim).orientation = 'xpos';
        span = [-135 135]; % hard-coded for now, specific to zultra rig
    else
        pars(iStim).orientation = 'ypos';
        span = [-45 45]; % hard-coded for now, specific to zultra rig
    end
    pars(iStim).startEndPos = interp1([0 360], span, p.pars([indStart, indEnd], iStim)');
    if p.pars(indDir, iStim) == -1
        pars(iStim).startEndPos = fliplr(pars(iStim).startEndPos);
    end
end