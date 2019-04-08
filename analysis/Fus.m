classdef Fus < handle
    
    properties
        ExpRef = '';
        yStack = [];
        doppler = [];
        dopplerFast = [];
        xAxis = [];
        zAxis = [];
        yCoord = [];
        tAxis = []; % onsets of doppler frames
        tAxisFast = []; % onsets of fast doppler frames
        dt = []; % duration of each doppler frame
        dtFast = []; % duration of each fast doppler frame
        protocol = []; % mpep protocol
        TL = []; % Timeline data
        hwInfo = []; % hardware info of the stimulus computer
        stim = []; % stimulus informaion
        stimTimes = []; % stimulus onset and offset times
        stimFrameTimes = [] % times of individual textures of the stimulus
        eyeMovie = []; % VideoReader object of the eye movie 
        eyeTimes = []; % timestamps of the eye movie frames
        
    end
    
    methods
        function obj = Fus(ExpRef)
            obj.ExpRef = ExpRef;
            obj.yStack = [];
            data = getExpData(ExpRef);
            obj.xAxis = data.doppler.xAxis;
            obj.zAxis = data.doppler.zAxis;
            obj.yCoord = data.doppler.motorPosition;
            obj.dt = data.fusiFrameDuration;
            obj.doppler = data.doppler.frames;
            obj.dopplerFast= cell2mat(reshape(data.doppler.fastFrames, 1, 1, []));
            obj.dtFast = data.doppler.dtFastFrames;
            obj.tAxis = data.fusiFrameOnsets;
            nFastFrames = size(data.doppler.fastFrames{1}, 3);
            obj.tAxisFast = reshape(bsxfun(@plus, obj.tAxis, obj.dtFast*(0:nFastFrames - 1))', [], 1);
            obj.protocol = data.p;
            obj.TL = data.TL;
            obj.hwInfo = data.hwInfo;
            obj.stim = data.stim;
            obj.stimTimes = data.stimTimes;
            obj.stimFrameTimes = data.stimFrameTimes;
            obj.eyeMovie = data.eyeMovie;
            obj.eyeTimes = data.eyeTimes;
        end
    end
end