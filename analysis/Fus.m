classdef Fus < handle
    
    properties
        ExpRef = '';
        yStack = [];
        doppler = [];
        dopplerFast = [];
        regDoppler = []; % registered Doppler data
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
        regDII = []; % delta I/I0 of the doppler signal post-registration
        retinotopyMaps;
        retinotopyMapsFast;
        svd = struct('V', []);
        svdReg = struct('V', []);
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
            if ~isempty(obj.regDoppler)
                I0 = median(obj.regDoppler(:, :, idx), 3);
                obj.regDII = bsxfun(@rdivide, bsxfun(@minus, obj.regDoppler, I0), I0);
            end
            idx = ~obj.outlierFrameIdxFast;
            I0Fast = median(obj.dopplerFast(:, :, idx), 3);
            obj.dIIFast = bsxfun(@rdivide, bsxfun(@minus, obj.dopplerFast, I0Fast), I0Fast);
        end
        
        function getRetinotopy(obj)
            idx = ~obj.outlierFrameIdx;
            idx = true(size(idx));
            stimPars = getStimPars(obj.protocol);
%             mov = obj.dII(:,:,idx);
            svdIdx = [1:100];
            U = obj.yStack.svdReg.UdII(:, :, svdIdx);
            S = obj.yStack.svdReg.SdII(svdIdx);
            V = obj.svdReg.VdII(:, svdIdx);
            [nz, nx, ~] = size(U);
            mov = reshape(U, nz*nx, []) * diag(S) * V';
            mov = reshape(mov, nz, nx, []);
            obj.retinotopyMaps = getPreferenceMaps(mov(:,:,idx), obj.tAxis(idx) + obj.dt/2, obj.stimTimes, stimPars);
            
            idx = ~obj.outlierFrameIdxFast;
            mov = obj.dIIFast(:,:,idx);
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
            plotPreferenceMaps(obj.retinotopyMaps, stimPars, showHemoDelay, plotType);
%             plotPreferenceMaps(obj.retinotopyMapsFast, stimPars, showHemoDelay, plotType);
        end
        
        function F = movie(obj, iSVD, reg)
            
            if nargin < 3
                reg = false;
            end
            
            if nargin < 2 || isempty(iSVD)
                if reg
                    mov = obj.regDoppler;
                else
                    mov = obj.doppler;
                end
            else
                nSVDs2Use = length(iSVD);
                if reg
                    U = obj.yStack.svdReg.U;
                    S = obj.yStack.svdReg.S;
                    V = obj.svdReg.V;
                    meanFrame = obj.yStack.svdReg.meanFrame;
                else
                    U = obj.yStack.svd.U;
                    S = obj.yStack.svd.S;
                    V = obj.svd.V;
                    meanFrame = obj.yStack.svd.meanFrame;
                end
                [nZ, nX, ~] = size(U);
                Uflat = reshape(U(:, :, iSVD), nZ*nX, nSVDs2Use);
                mov = Uflat * diag(S(iSVD)) * V(:, iSVD)';
                mov = reshape(mov, nZ, nX, []);
                mov = bsxfun(@plus, mov, meanFrame);
            end
            mov = log10(mov - min(mov(:)));
            nFrames = size(mov, 3);
            % calculate the clim not including the masked out regions
            clim = prctile(mov(:), [0.01 99.99]);
%             clim = prctile(log10(obj.doppler(:)-min(obj.doppler(:))), [0.01 99.99]);
            hFig = figure;
            colormap hot;
            if nargout > 0
                F = struct('cdata', [], 'colormap', []);
                F = repmat(F, nFrames, 1);
            end
            for iFrame = 1:nFrames
                if iFrame == 1
                    im = imagesc(obj.xAxis-mean(obj.xAxis), obj.zAxis-obj.zAxis(1), mov(:,:,iFrame));
                    tit = title(sprintf('%3.1f/%2.0f [s]', obj.tAxis(iFrame), obj.tAxis(nFrames)));
                    caxis(clim);
                    cb = colorbar;
                    cb.Label.String = 'log_{10}(I)';
                    axis equal tight off;
                else
                    im.CData = mov(:,:,iFrame);
                    tit.String = sprintf('%3.1f/%2.0f [s]', obj.tAxis(iFrame), obj.tAxis(nFrames));
                end
                drawnow;
%                 pause(0.05);
                if nargout > 0
                    F(iFrame) = getframe(hFig);
                end
            end
        end
        
        function F = dIIMovie(obj, iSVD, reg)
            
            if nargin < 3
                reg = false;
            end

            if nargin < 2 || isempty(iSVD)
                if reg
                    mov = obj.regDII;
                else
                    mov = obj.dII;
                end
            else
                if reg
                    U = obj.yStack.svdReg.UdII;
                    S = obj.yStack.svdReg.SdII;
                    V = obj.svdReg.VdII;
                else
                    U = obj.yStack.svd.UdII;
                    S = obj.yStack.svd.SdII;
                    V = obj.svd.VdII;
                end
                nSVDs2Use = length(iSVD);
                [nZ, nX, ~] = size(U);
                Uflat = reshape(U(:, :, iSVD), nZ*nX, nSVDs2Use);
                mov = Uflat * diag(S(iSVD)) * V(:, iSVD)';
                mov = reshape(mov, nZ, nX, []);
            end
            nFrames = size(mov, 3);
%             mov = imgaussfilt3(mov, 2);
            % calculate the clim not including the masked out regions
            clim = prctile(mov(:), [0.5 99.5]);
            % make clim symmetric (should be more informative when looking at dI/I0)
            clim = [-1 1]*max(abs(clim));
            hFig = figure;
            % create a blue-white-red colormap with white == 0
            r = [linspace(0, 1, 32), ones(1, 32)]';
            g = [linspace(0, 1, 32), linspace(1, 0, 32)]';
            b = flipud(r);
            % (colormap).^(1/n) will make the white region wider
            colormap(([r, g, b]).^(1/2));
%             colormap hot
            mov(isnan(mov)) = 0;

            if nargout > 0
                F = struct('cdata', [], 'colormap', []);
                F = repmat(F, nFrames, 1);
            end

            for iFrame = 1:nFrames
                if iFrame == 1
                    im = imagesc(obj.xAxis-mean(obj.xAxis), obj.zAxis-obj.zAxis(1), mov(:,:,iFrame));
                    tit = title(sprintf('%3.1f/%2.0f [s]', obj.tAxis(iFrame), obj.tAxis(nFrames)));
                    caxis(clim);
                    cb = colorbar;
                    cb.Label.String = '\DeltaI/I_0';
                    axis equal tight off;
                else
                    im.CData = mov(:,:,iFrame);
                    tit.String = sprintf('%3.1f/%2.0f [s]', obj.tAxis(iFrame), obj.tAxis(nFrames));
                end
                drawnow;
%                 pause(0.08);
                if nargout > 0 
                    F(iFrame) = getframe(hFig);
                end
            end
        end
        
    end
end