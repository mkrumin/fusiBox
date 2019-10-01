function out = getExpData(ExpRef)

try
    p = getMpepProtocol(ExpRef);
    isMpep = true;
    block = [];
    pars = [];
catch e
    p = [];
    isMpep = false;
    try
        [block, pars] = getBlockAndPars(ExpRef);
    catch e2
        warning(e.identifier, 'Couldn''t load the mpep protocol file:\n%s\n', e.message);
        warning(e2.identifier, 'Also couldn''t load the block file and/or the parameters:\n%s\n', e2.message);
        block = [];
        pars = [];
    end
end

try
    hwInfo = getHardwareInfo(ExpRef);
catch e
    warning(e.identifier, 'Couldn''t load hardwareInfo file:\n%s\n', e.message);
    hwInfo = [];
end

Timeline = getTimeline(ExpRef);

stim = [];
stimTimes = [];
frameTimes = [];
stimSeq = [];
if isMpep
    try
        stim = getStimTextures(hwInfo, p.pars, p.xfile);
    catch e
        warning(e.identifier, 'Couldn''t get stim textures of an mpep experiment:\n%s\n', e.message);
    end
    % converting from cell array to a 3D matrix
    % stimTextures = cell2mat(reshape(stim{1}.stimTextures(stim{1}.textureSequence), 1, 1, length(stim{1}.textureSequence)));
    
    try
        [stimTimes, frameTimes] = getStimTimes(Timeline, p);
    catch e
        warning(e.identifier, 'Couldn''t get mpep/tlvs stim times:\n%s\n', e.message);
    end
    
else
    filename = dat.expFilePath(ExpRef, 'block', 'master');
    filename = strrep(filename, '_Block.mat', '_ProcBlock.mat');
    try
        d = load(filename);
        stimTimes = d.fus;
        stimSeq = d.blk;
    catch e
        warning(e.identifier, 'Couldn''t get preprocessed stim times from ''_ProcBlock'' file:\n%s\n', e.message);
    end
end

doppler = getDoppler(ExpRef);

try
    nBFPerFrame = doppler.nBFPerFrame;
catch
    nBFPerFrame = doppler.params.sizeBF(3);
end
bfRate = 1/doppler.dtBF;
fusiFrameDuration = doppler.dtBF * nBFPerFrame;

switch doppler.params.fusVersion
    case 'R07PX'
        % these are the 'neuralFrames' from Timeline (onsets of single
        % blocks of 100 ms of acquisition)
        neuralFrames = getFrameTimes(Timeline);
        % depending on the amount of averaging done during the acquisition
        % we should decimate the TTLs to aligh with the acquired
        % microDopper frames
        nBlocks = doppler.params.Nblock;
        fusiFrameOnsets = neuralFrames(1:nBlocks:end);
        % and these will be the 'middles' of the frames
        fusiFrameTimes = fusiFrameOnsets + nBFPerFrame/2/bfRate;
        % and this will be the short time axis of the BF frames within a single
        % Power Doppler frame
        timesBF = doppler.dtBF * [0:nBFPerFrame-1];
        
        % we will get several frames in the beginning of the acquisition,
        % which do not have corresponding 'neuralFrames', because they were
        % acruired before the Timeline started (as we first start the fUSi
        % acquisition in a 'paused' mode)
        nSkipFrames = 5;
        doppler.frames = doppler.frames(:, :, nSkipFrames+1:end);
        doppler.softTimes = doppler.softTimes(nSkipFrames+1:end);
        if isfield(doppler, 'fastFrames')
            doppler.fastFrames = doppler.fastFrames(nSkipFrames+1:end);
        else
            % for experiments, which do not have fast data
            doppler.fastFrames = cell(0);
        end
        
        % Let's make sure we have the same number of frames and timestamps
        nTimes = length(fusiFrameTimes);
        nSlowFrames = size(doppler.frames, 3);
        nFastFrames = length(doppler.fastFrames);
        if nFastFrames>0
            nFramesFinal = min(nTimes, min(nSlowFrames, nFastFrames));
            doppler.fastFrames = doppler.fastFrames(1:nFramesFinal);
        else
            nFramesFinal = min(nTimes, nSlowFrames);
        end
        doppler.frames = doppler.frames(:, :, 1:nFramesFinal);
        doppler.softTimes = doppler.softTimes(1:nFramesFinal);
        fusiFrameTimes = fusiFrameTimes(1:nFramesFinal);
        fusiFrameOnsets = fusiFrameOnsets(1:nFramesFinal);
        
    otherwise
        % these are the frame onsets
        fusiFrameOnsets = getFrameTimes(Timeline);
        % and these will be the 'middles' of the frames
        fusiFrameTimes = fusiFrameOnsets + nBFPerFrame/2/bfRate;
        % and this will be the short time axis of the BF frames within a single
        % Power Doppler frame
        timesBF = doppler.dtBF * [0:nBFPerFrame-1];
        
        % the last two frames acquired by the Verasonics are not
        % getting processes and are not making it into the final data
        fusiFrameTimes = fusiFrameTimes(1:end-2);
        fusiFrameOnsets = fusiFrameOnsets(1:end-2);
        % Timeline might miss the first few frames
        % Also, the first frame of the movie is acquired before the experiment
        % starts, the way acquisition currently works
        nFramesAcquired = length(fusiFrameTimes);
        
        nSkipFrames = length(doppler.softTimes) - nFramesAcquired;
        doppler.frames = doppler.frames(:, :, nSkipFrames+1:end);
        doppler.softTimes = doppler.softTimes(nSkipFrames+1:end);
        if isfield(doppler, 'fastFrames')
            doppler.fastFrames = doppler.fastFrames(nSkipFrames+1:end);
        else
            % for experiments, which do not have fast data
            doppler.fastFrames = cell(0);
        end
end
try
    eyeFilename = dat.expFilePath(ExpRef, 'eyetracking');
    if exist([eyeFilename{1}, '.mj2'], 'file')
        eyeFilename = [eyeFilename{1}, '.mj2'];
    else
        eyeFilename = [eyeFilename{2}, '.mj2'];
    end
    eyeMovie = VideoReader(eyeFilename);
catch e
    fprintf('There was a problem getting the eye-camera video: %s\n', e.message)
    eyeMovie = [];
end
try
    eyeTimes = et.getFrameTimes(ExpRef);
catch e
    fprintf('There was a problem getting the eye-camera timestamps: %s\n', e.message)
    eyeTimes = [];
end

out.p = p; % mpep Protocol
out.block = block; % block-file of the mc/expServer-style experiment
out.pars = pars; % parameters of the mc/expServer experiment
out.hwInfo = hwInfo; % hardware info for the stimulus monitors
out.stim = stim; % stimulus textures
out.TL = Timeline;
out.stimTimes = stimTimes; % onsets and offsets of the stimuli
out.stimFrameTimes = frameTimes; % timeStamps of the stimulus frames
out.stimSequence = stimSeq; % sequence of stimuli for mc/expServer experiment
out.doppler = doppler; % fUSi data
out.fusiFrameOnsets = fusiFrameOnsets; % onset timestamps of fUSi frames
out.fusiFrameDuration = fusiFrameDuration; % duration of each fUSi frame
out.fusiFrameTimes = fusiFrameTimes; % timestamps of the 'middles' of the fUSi frames
out.eyeMovie = eyeMovie; % VideoReader object of the eye movie
out.eyeTimes = eyeTimes; % timestamps of the eye movie