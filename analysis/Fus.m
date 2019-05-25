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
        block = []; % block file data for the mc/expServer experiment
        pars = []; % parameters of the mc/expServer experiment
        TL = []; % Timeline data
        hwInfo = []; % hardware info of the stimulus computer
        stim = []; % stimulus informaion
        stimTimes = []; % stimulus onset and offset times
        stimFrameTimes = []; % times of individual textures of the stimulus
        stimSequence = []; % sequence of stimuli during the mc/expServer experiment
        eyeMovie = []; % VideoReader object of the eye movie
        eyeTimes = []; % timestamps of the eye movie frames
        outlierFrameIdx = [];
        outlierFrameIdxFast = [];
        dII = []; % delta I/I0 of the doppler signal
        dIIFast = []; % delta I/I0 of the fast doppler signal
        retinotopyMaps;
        retinotopyMapsFast;
        svd = struct('V', []);
    end
    
    methods
        function obj = Fus(ExpRef, ys)
            obj.ExpRef = ExpRef;
            if nargin > 1
                obj.yStack = ys;
            else
                obj.yStack = [];
            end
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
            obj.block = data.block;
            obj.pars = data.pars;
            obj.TL = data.TL;
            obj.hwInfo = data.hwInfo;
            obj.stim = data.stim;
            obj.stimTimes = data.stimTimes;
            obj.stimFrameTimes = data.stimFrameTimes;
            obj.stimSequence = data.stimSequence;
            obj.eyeMovie = data.eyeMovie;
            obj.eyeTimes = data.eyeTimes;
            obj.outlierFrameIdx = false(length(obj.tAxis), 1);
            obj.outlierFrameIdxFast = false(length(obj.tAxisFast), 1);
        end
        
        function getOutliers(obj, nMAD)
            idxX = obj.xAxis >= obj.yStack.boundingBox.x(1) & obj.xAxis <= obj.yStack.boundingBox.x(2);
            idxZ = obj.zAxis >= obj.yStack.boundingBox.z(1) & obj.zAxis <= obj.yStack.boundingBox.z(2);
            
            prcThresh = 95;
            if nargin<2
                nMAD = 3;
            end
            
            mov = obj.doppler(idxZ, idxX, :);
            meanFrame = mean(mov, 3);
            stdFrame = std(mov, [], 3);
            cvFrame = stdFrame./meanFrame;
            
            [nZ, nX, nFrames] = size(mov);
            mov = reshape(mov, nZ*nX, nFrames);
            idxCV = cvFrame > prctile(cvFrame(:), prcThresh);
            trace = mean(mov(idxCV, :));
            thr = median(trace) + nMAD*mad(trace, 1);
            obj.outlierFrameIdx = trace > thr;
            
            mov = obj.dopplerFast(idxZ, idxX, :);
            meanFrame = mean(mov, 3);
            stdFrame = std(mov, [], 3);
            cvFrame = stdFrame./meanFrame;
            
            [nZ, nX, nFrames] = size(mov);
            mov = reshape(mov, nZ*nX, nFrames);
            idxCV = cvFrame > prctile(cvFrame(:), prcThresh);
            trace = mean(mov(idxCV, :));
            thr = median(trace) + nMAD*mad(trace, 1);
            obj.outlierFrameIdxFast = trace > thr;
            
        end
        
        function [mov, xx, zz, movFast] = getCroppedDoppler(obj)
            idxX = obj.xAxis >= obj.yStack.boundingBox.x(1) & obj.xAxis <= obj.yStack.boundingBox.x(2);
            idxZ = obj.zAxis >= obj.yStack.boundingBox.z(1) & obj.zAxis <= obj.yStack.boundingBox.z(2);
            mov = obj.doppler(idxZ, idxX, :);
            xx = obj.xAxis(idxX);
            zz = obj.zAxis(idxZ);
            if nargout > 3
                movFast = obj.dopplerFast(idxZ, idxX, :);
            end
        end
        
        function hardCrop(obj)
            [mov, xx, zz, movFast] = getCroppedDoppler(obj);
            obj.doppler = mov;
            obj.dopplerFast = movFast;
            obj.xAxis = xx;
            obj.zAxis = zz;
        end
        
        function getdII(obj)
            idx = ~obj.outlierFrameIdx;
            I0 = median(obj.doppler(:, :, idx), 3);
            obj.dII = bsxfun(@rdivide, bsxfun(@minus, obj.doppler, I0), I0);
            idx = ~obj.outlierFrameIdxFast;
            I0Fast = median(obj.dopplerFast(:, :, idx), 3);
            obj.dIIFast = bsxfun(@rdivide, bsxfun(@minus, obj.dopplerFast, I0Fast), I0Fast);
        end
        
        function getRetinotopy(obj)
            idx = ~obj.outlierFrameIdx;
            stimPars = getStimPars(obj.protocol);
            obj.retinotopyMaps = getPreferenceMaps(obj.dII(:,:,idx), obj.tAxis(idx) + obj.dt/2, obj.stimTimes, stimPars);
            
            idx = ~obj.outlierFrameIdxFast;
            mov = obj.dIIFast(:,:,idx);
            mov = mov - rmSVD(mov, 100);
            obj.retinotopyMapsFast = getPreferenceMaps(mov, obj.tAxisFast(idx) + obj.dtFast/2, ...
                obj.stimTimes, stimPars);
        end
        
        function showRetinotopy(obj, showHemoDelay, plotType)
            if nargin < 2
                showHemoDelay = false;
            end
            if nargin < 3
                plotType = '';
            end
            stimPars = getStimPars(obj.protocol);
            nStims = length(stimPars);
            for iStim = 1:nStims
                stimPars(iStim).xAxis = obj.xAxis;
                stimPars(iStim).yAxis = obj.zAxis;
            end
            %             plotPreferenceMaps(obj.retinotopyMaps, stimPars, showHemoDelay, plotType);
            plotPreferenceMaps(obj.retinotopyMapsFast, stimPars, showHemoDelay, plotType);
        end
        
        function F = movie(obj, iSVD)
            
            if nargin < 2
                mov = obj.doppler;
            else
                nSVDs2Use = length(iSVD);
                [nZ, nX, nSVD] = size(obj.yStack.svd.U);
                Uflat = reshape(obj.yStack.svd.U(:, :, iSVD), nZ*nX, nSVDs2Use);
                mov = Uflat * diag(obj.yStack.svd.S(iSVD)) * obj.svd.V(:, iSVD)';
                mov = reshape(mov, nZ, nX, []);
                mov = bsxfun(@plus, mov, obj.yStack.svd.meanFrame);
            end
            idxZeroes = obj.doppler(:) == 0; % these are the masked out pixels
            mov = log10(mov - min(mov(:)));
            nFrames = size(mov, 3);
            % calculate the clim not including the masked out regions
            clim = prctile(mov(~idxZeroes), [0.01 99.99]);
%             clim = prctile(log10(obj.doppler(~idxZeroes)-min(obj.doppler(:))), [0.01 99.99]);
            hFig = figure;
            colormap hot;
            for iFrame = 1:nFrames
                if iFrame == 1
                    im = imagesc(obj.xAxis-mean(obj.xAxis), obj.zAxis-obj.zAxis(1), mov(:,:,iFrame));
                    tit = title(sprintf('%g/%g', iFrame, nFrames));
                    caxis(clim);
                    cb = colorbar;
                    cb.Label.String = 'log_{10}(I)';
                    axis equal tight off;
                else
                    im.CData = mov(:,:,iFrame);
                    tit.String = sprintf('%g/%g', iFrame, nFrames);
                end
                drawnow;
                %                 pause(0.05);
                %                 F(iFrame) = getframe(hFig);
            end
        end
    end
end