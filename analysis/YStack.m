classdef YStack < handle & matlab.mixin.Copyable
    
    properties
        ExpRef = '';
        xAxis = [];
        zAxis = [];
        yAxis = [];
        boundingBox = struct('x', [], 'y', [], 'z', []);
        mask = struct('y', [], 'bw', [], 'poly', []); % mask to be applied to functional data
        Doppler = [];
        BMode = [];
        fusi; % array of related Fus objects
        svd = struct('meanFrame', [], 'U', [], 'UdII', [], 'S', []);
        svdReg = struct('meanFrame', [], 'U', [], 'UdII', [], 'S', []);
        regParams = struct('nSVDs', [], 'nIter', [], 'AFS', []); % parameters used for registration
    end
    
    methods
        function obj = YStack(ExpRef)
            obj.ExpRef = ExpRef;
            data = load(fullfile(dat.expPath(ExpRef, 'main', 'master'), ...
                [ExpRef, '_fUSiYStack.mat']));
            obj.xAxis = data.Doppler.xAxis;
            obj.zAxis = data.Doppler.zAxis;
            obj.yAxis = data.yCoords;
            obj.Doppler = squeeze(min(data.Doppler.yStack, [], 3));
            obj.BMode = data.BMode;
            obj.BMode.yStack = squeeze(obj.BMode.yStack);
            obj.BMode.yAxis = data.yCoords;
            obj.boundingBox.x = [min(obj.xAxis), max(obj.xAxis)];
            obj.boundingBox.y = [min(obj.yAxis), max(obj.yAxis)];
            obj.boundingBox.z = [min(obj.zAxis), max(obj.zAxis)];
            obj.autoCrop;
        end
        
        function h = manualCrop(obj)
            h = figure;
            data = max(obj.Doppler, [], 3);
            data = sqrt(data);
            imagesc(obj.xAxis, obj.zAxis, data);
            axis equal tight;
            colormap hot
            caxis(prctile(data(:), [1 99]));
            title('Draw a rectangle surrounding the brain, then double click it');
            xminmax = obj.boundingBox.x;
            zminmax = obj.boundingBox.z;
            ic = [xminmax(1), zminmax(1), diff(xminmax), diff(zminmax)];
            hRect = imrect(gca, ic);
            pos = wait(hRect);
            delete(hRect);
            [~, ind] = min(abs(obj.xAxis - pos(1)));
            xMin = obj.xAxis(ind);
            [~, ind] = min(abs(obj.xAxis - pos(1) - pos(3)));
            xMax = obj.xAxis(ind);
            [~, ind] = min(abs(obj.zAxis - pos(2)));
            zMin = obj.zAxis(ind);
            [~, ind] = min(abs(obj.zAxis - pos(2) - pos(4)));
            zMax = obj.zAxis(ind);
            xlim([xMin, xMax]);
            ylim([zMin, zMax]);
            title('This will be the bounding box for this stack');
            obj.boundingBox.x = [xMin, xMax];
            obj.boundingBox.z = [zMin, zMax];
        end
        
        function autoCrop(obj, doPlotting)
            if nargin < 2
                doPlotting = false;
            end
            data = max(obj.Doppler, [], 3);
            data = sqrt(data);
            xProjection = imgaussfilt(median(data, 1), 1);
            zProjection = imgaussfilt(median(data, 2), 1.2);
            xThreshold = min(xProjection(:)) + 0.2 * (max(xProjection(:)) - min(xProjection(:)));
            zThreshold = min(zProjection(:)) + 0.05 * (max(zProjection(:)) - min(zProjection(:)));
            % using imfill to find a region around the maximum, which is
            % all above threshold
            [~, xMaxLoc] = max(xProjection(:));
            xIdx = imfill(xProjection < xThreshold, xMaxLoc) - (xProjection < xThreshold);
            xMinInd = find(xIdx, 1, 'first');
            xMin = obj.xAxis(xMinInd);
            xMaxInd = find(xIdx, 1, 'last');
            xMax = obj.xAxis(xMaxInd);
            [~, zMaxLoc] = max(zProjection(:));
            zIdx = imfill(zProjection < zThreshold, zMaxLoc) - (zProjection < zThreshold);
            zMinInd = find(zIdx, 1, 'first');
            zMin = obj.zAxis(zMinInd);
            zMaxInd = find(zIdx, 1, 'last');
            zMax = obj.zAxis(zMaxInd);
            
            %             This older version finding the first and last threshold crossings
            %             fails if there are some artefacts near the edgesversion
            %             xMinInd = find(xProjection > xThreshold, 1, 'first');
            %             xMin = obj.xAxis(xMinInd);
            %             xMaxInd = find(xProjection > xThreshold, 1, 'last');
            %             xMax = obj.xAxis(xMaxInd);
            %             zMinInd = find(zProjection > zThreshold, 1, 'first');
            %             zMin = obj.zAxis(zMinInd);
            %             zMaxInd = find(zProjection > zThreshold, 1, 'last');
            %             zMax = obj.zAxis(zMaxInd);
            
            obj.boundingBox.x = [xMin, xMax];
            obj.boundingBox.z = [zMin, zMax];
            
            % plotting below is for for debugging
            if doPlotting
                figure;
                subplot(2, 2, 2)
                imagesc(obj.xAxis, obj.zAxis, data);
                axis equal tight;
                colormap hot
                caxis(prctile(data(:), [1 99]));
                hold on;
                rectangle(gca, 'Position', [xMin, zMin, xMax-xMin, zMax-zMin], 'EdgeColor', 'w', 'LineWidth', 2);
                subplot(2, 2, 1);
                plot(zProjection, obj.zAxis);
                hold on;
                axis tight ij
                set(gca, 'XDir', 'reverse');
                plot([zThreshold, zThreshold], ylim, 'r--');
                plot(xlim, [zMin, zMin], 'g--');
                plot(xlim, [zMax, zMax], 'g--');
                subplot(2, 2, 4);
                plot(obj.xAxis, xProjection);
                hold on;
                axis tight
                plot(xlim, [xThreshold, xThreshold], 'r--');
                plot([xMin, xMin], ylim, 'g--');
                plot([xMax, xMax], ylim, 'g--');
            end
        end
        
        function hFig = plotVolume(obj, hAxis, alphaPower, azel)
            if nargin < 2
                hAxis = [];
            end
            if nargin < 3
                alphaPower = 2.5;
            end
            if nargin < 4
                azel = [];
            end
            xLimits = obj.boundingBox.x;
            zLimits = obj.boundingBox.z;
            xIdx = obj.xAxis >= xLimits(1) & obj.xAxis <= xLimits(2);
            zIdx = obj.zAxis >= zLimits(1) & obj.zAxis <= zLimits(2);
            xx = obj.xAxis(xIdx);
            xx = xx - mean(xx);
            yy = obj.yAxis;
            zz = obj.zAxis(zIdx);
            zz = zz - zz(1);
            [X, Y, Z] = meshgrid(xx, yy, zz);
            % we need to make the first dimension to be Y, second - X, and third - Z
            stack = permute(obj.Doppler(zIdx, xIdx, :), [3 2 1]);
            stack = -stack.^(1/2);
            dX = diff(xx(1:2));
            dY = diff(yy(1:2));
            dZ = diff(zz(1:2));
            stack = imgaussfilt3(stack, 0.05./[dX, dY, dZ]);
            
            if isempty(hAxis)
                hFig = figure('Name', obj.ExpRef);
                ax = subplot(1, 1, 1);
            else
                hFig = hAxis.Parent;
                ax = hAxis;
            end
            hSlice = slice(X, Y, Z, stack, xx, yy, zz, 'linear');
            [cMinMax] = prctile(stack(:), [0.1 99]);
            caxis(cMinMax);
            colormap(ax, 'hot')
            alphaVal = (stack-cMinMax(1))/diff(cMinMax);
            % clip the alpha mask to be between 0 and 1
            alphaVal = max(min(alphaVal, 1), 0);
            alphaVal = 1-alphaVal;
            % apply appropriate transparency to each slice object
            for i = 1:length(hSlice)
                hSlice(i).LineStyle = 'none';
                hSlice(i).FaceAlpha = 'flat';
                if (max(hSlice(i).XData(:)) - min(hSlice(i).XData(:))) == 0
                    ind = find(xx == hSlice(i).XData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(:, ind, :).^alphaPower);
                elseif (max(hSlice(i).YData(:)) - min(hSlice(i).YData(:))) == 0
                    ind = find(yy == hSlice(i).YData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(ind, :, :).^alphaPower);
                elseif (max(hSlice(i).ZData(:)) - min(hSlice(i).ZData(:))) == 0
                    ind = find(zz == hSlice(i).ZData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(:, :, ind).^alphaPower);
                end
            end
            ax.DataAspectRatio = [1 1 1];
            ax.CameraViewAngle = 9;
            ax.ZDir = 'reverse';
            if isempty(azel)
                view(ax, -30, 20);
            else
                view(ax, azel(1), azel(2));
            end
            axis(ax, 'tight');
            ax.XLabel.String = 'ML [mm]';
            ax.YLabel.String = 'AP [mm]';
            ax.ZLabel.String = 'DV [mm]';
            if isempty(hAxis)
                title(ax, strrep(obj.ExpRef, '_', '\_'));
            end
            
        end
        
        function hFig = plotVolumeMultiple(obj, alphaPower)
            if nargin < 2
                alphaPower = 2.5;
            end
            hFig = figure('Name', obj.ExpRef);
            az = [-30 0 30];
            el = [40 20];
            [ell, azz] = meshgrid(el, az);
            azel = [azz(:), ell(:)];
            for iPlot = 1:length(azz(:))
                ax = subplot(length(el), length(az), iPlot);
                obj.plotVolume(ax, alphaPower, azel(iPlot, :));
            end
            
        end
        
        function plotSlices(obj, sliceIdx)
            if nargin < 2
                nSlices = length(obj.yAxis);
                sliceIdx = 1:length(obj.yAxis);
                printAxesTitles = false;
            else
                nSlices = length(sliceIdx);
                printAxesTitles = true;
            end
            nRows = floor(sqrt(nSlices));
            nColumns = ceil(nSlices/nRows);
            
            xIdx = obj.xAxis >= obj.boundingBox.x(1) & obj.xAxis <= obj.boundingBox.x(2);
            xx = obj.xAxis(xIdx);
            xx = xx - mean(xx);
            zIdx = obj.zAxis >= obj.boundingBox.z(1) & obj.zAxis <= obj.boundingBox.z(2);
            zz = obj.zAxis(zIdx);
            zz = zz - zz(1);
            
            data = (obj.Doppler(zIdx, xIdx, :));
            data = sqrt(data);
            cminmax = prctile(data(:), [1 99]);
            hFig = figure('Name', obj.ExpRef);
            for iSlice = 1:nSlices
                ax = subplot(nRows, nColumns, iSlice);
                [iColumn, iRow] = ind2sub([nColumns, nRows], iSlice);
                imagesc(xx, zz, (data(:, :, sliceIdx(iSlice))));
                axis equal tight
                caxis(cminmax);
                colormap hot;
                if iRow == nRows && iColumn == 1
                    xlabel('ML [mm]');
                    ylabel('DV [mm]');
                else
                    set(gca, 'XTickLabel', '', 'YTickLabel', '');
                end
                if printAxesTitles
                    title(obj.yAxis(sliceIdx(iSlice)))
                end
                ax.Position = ax.Position + [-0.01 -0.01 0.02 0.02];
                ax.FontSize = 14;
            end
        end
        
        function F = renderVolumeRotation(obj)
            h = obj.plotVolume;
            ax = gca; % assuming there is only one axes
            % switching off axis, labels, and title
            axis off tight;
            ax.Title.Visible = 'off';
            %             ax.CameraTargetMode = 'manual';
            azimuth = -30 + [0:1:359];
            nFrames = length(azimuth);
            view(ax, azimuth(1), 20)
            drawnow;
            F = getframe(h);
            for iFrame = 2:nFrames
                fprintf('Rendering frame #%g/%g\n', iFrame, nFrames);
                view(ax, azimuth(iFrame), 20)
                drawnow;
                F(iFrame) = getframe(h);
            end
        end
        
        function data = getDoppler(obj)
            xIdx = obj.xAxis >= obj.boundingBox.x(1) & obj.xAxis <= obj.boundingBox.x(2);
            zIdx = obj.zAxis >= obj.boundingBox.z(1) & obj.zAxis <= obj.boundingBox.z(2);
            yIdx = obj.yAxis >= obj.boundingBox.y(1) & obj.yAxis <= obj.boundingBox.y(2);
            data.doppler = obj.Doppler(zIdx, xIdx, yIdx);
            data.xAxis = obj.xAxis(xIdx);
            data.yAxis = obj.yAxis(yIdx);
            data.zAxis = obj.zAxis(zIdx);
        end
        
        function addFus(obj, ExpRef)
            if isempty(obj.fusi)
                obj.fusi = Fus(ExpRef, obj);
            else
                nFusNow = length(obj.fusi);
                obj.fusi(nFusNow + 1) = Fus(ExpRef, obj);
            end
        end
        
        function getOutliers(obj, nMAD)
            for iFus = 1:length(obj.fusi)
                if nargin < 2
                    obj.fusi(iFus).getOutliers;
                else
                    obj.fusi(iFus).getOutliers(nMAD);
                end
            end
        end
        
        function getdII(obj)
            for iFus = 1:length(obj.fusi)
                obj.fusi(iFus).getdII;
            end
        end
        
        function svddII(obj, reg)
            if ~reg
                obj.svd.UdII = bsxfun(@rdivide, obj.svd.U, obj.svd.meanFrame);
            else
                obj.svdReg.UdII = bsxfun(@rdivide, obj.svdReg.U, obj.svdReg.meanFrame);
            end
            obj.rotateUdII(reg);
        end
        
        function getRetinotopy(obj)
            % figure out which of the experiments is Kalatsky
            protocols = {obj.fusi.protocol};
            mpepID = find(~cellfun(@isempty, protocols));
            isKalatsky = ismember({protocols{mpepID}.xfile}, 'stimKalatsky.x');
            fusID = mpepID(isKalatsky);
            if isempty(obj.fusi(fusID).retinotopyMapsFast)
                % if not done already, perform the analyses
                if isempty(obj.fusi(fusID).outlierFrameIdxFast)
                    obj.fusi(fusID).getOutliers(Inf);
                end
                if isempty(obj.fusi(fusID).dIIFast)
                    obj.fusi(fusID).getdII;
                end
                obj.fusi(fusID).getRetinotopy;
            end
            % plot retinotopy
            obj.fusi(fusID).showRetinotopy;
        end
        
        function getMask(obj)
            yPos = unique([obj.fusi.yCoord]);
            % usually should only be one yPos, but let's code it for a
            % general scenario (i.e. several slices were acuired in the same experiment)
            for iSlice = 1:length(yPos)
                yInd = find(round(obj.yAxis, 1) == round(yPos(iSlice), 1));
                zIdx = find(obj.zAxis >= obj.boundingBox.z(1) & obj.zAxis <= obj.boundingBox.z(2));
                xIdx = find(obj.xAxis >= obj.boundingBox.x(1) & obj.xAxis <= obj.boundingBox.x(2));
                im = obj.Doppler(zIdx, xIdx, yInd);
                im = sqrt(im - min(im(:)));
                figure;
                hIm = imagesc(obj.xAxis(xIdx), obj.zAxis(zIdx), im);
                axis equal tight
                colormap hot;
                caxis(prctile(im(:), [1 99]));
                if length(obj.mask) >= iSlice && ~isempty(obj.mask(iSlice).poly)
                    xx = obj.mask.poly(:,1);
                    yy = obj.mask.poly(:,2);
                else
                    xMinMax = xlim;
                    zMinMax = ylim;
                    xx = [xMinMax, linspace(xMinMax(2), xMinMax(1), 7)]';
                    yy = [repmat(zMinMax(2), 1, 2),  repmat(zMinMax(1), 1, 7)]';
                end
                hPoly = drawpolygon(gca, 'Position', [xx, yy], 'LineWidth', 1, 'FaceAlpha', 0.4);
                roiWait(hPoly);
                obj.mask(iSlice).y = yPos(iSlice);
                obj.mask(iSlice).bw = createMask(hPoly);
                obj.mask(iSlice).poly = hPoly.Position;
                hIm.CData = hIm.CData.*obj.mask(iSlice).bw;
                hPoly.Visible = 'off';
            end
        end
        
        function applyMask(obj)
            nFusi = length(obj.fusi);
            for iFus = 1:nFusi
                % assuming that all the data is already hard-cropped to the
                % obj.boundingBox limits
                iMask = find(obj.fusi(iFus).yCoord == [obj.mask.y]);
                nanMask = single(obj.mask(iMask).bw);
                nanMask(~nanMask) = NaN;
                obj.fusi(iFus).doppler = bsxfun(@times, obj.fusi(iFus).doppler, nanMask);
                obj.fusi(iFus).dopplerFast = bsxfun(@times, obj.fusi(iFus).dopplerFast, nanMask);
            end
        end
        
        function svdDecomposition(obj, nSVDs, reg)
            if nargin < 3
                % in this case perform SVD on doppler, otherwise on regDoppler
                reg = false;
            end
            
            if reg
                oneBigDopplerMovie = cell2mat(reshape({obj.fusi.regDoppler}, 1, 1, []));
            else
                oneBigDopplerMovie = cell2mat(reshape({obj.fusi.doppler}, 1, 1, []));
            end
            meanFrame = median(oneBigDopplerMovie, 3);
            oneBigDopplerMovie = bsxfun(@minus, oneBigDopplerMovie, meanFrame);
            [nz, nx, nt] = size(oneBigDopplerMovie);
            [U, S, V] = nanSVD(oneBigDopplerMovie, nSVDs);
            if ~reg
                obj.svd.meanFrame = meanFrame;
                obj.svd.U = reshape(U, nz, nx, nSVDs);
                obj.svd.S = diag(S);
            else
                obj.svdReg.meanFrame = meanFrame;
                obj.svdReg.U = reshape(U, nz, nx, nSVDs);
                obj.svdReg.S = diag(S);
            end
            nFusi = length(obj.fusi);
            nFrames = cellfun(@size, {obj.fusi.doppler}, repmat({3}, 1, nFusi));
            endIdx = cumsum(nFrames);
            startIdx = [1, endIdx(1:nFusi-1)+1];
            for iFus = 1:nFusi
                idx = startIdx(iFus):endIdx(iFus);
                if ~reg
                    obj.fusi(iFus).svd.V = V(idx, :);
                else
                    obj.fusi(iFus).svdReg.V = V(idx, :);
                end
            end
        end
        
        function plotSVDs(obj, iSVD, regFlag, dIIFlag)
            if nargin < 3 || isempty(regFlag)
                regFlag = false;
            end
            if nargin < 4 || isempty(dIIFlag)
                dIIFlag = false;
            end
            
            nSVDs = length(iSVD);
            nRows = floor(sqrt(nSVDs));
            nColumns = ceil(nSVDs/nRows);
            hFig = figure;
            % create a blue-white-red colormap with white == 0
            r = [linspace(0, 1, 32), ones(1, 32)]';
            g = [linspace(0, 1, 32), linspace(1, 0, 32)]';
            b = flipud(r);
            % (colormap).^(1/n) will make the white region wider
            colormap(([r, g, b]).^(1/2));
%             colormap hot;
            if regFlag
                if dIIFlag
                    sVals = obj.svdReg.SdII(iSVD);
                    U = obj.svdReg.UdII;
                else
                    sVals = obj.svdReg.S(iSVD);
                    U = obj.svdReg.U;
                end
            else
                if dIIFlag
                    sVals = obj.svd.SdII(iSVD);
                    U = obj.svd.UdII;
                else
                    sVals = obj.svd.S(iSVD);
                    U = obj.svd.U;
                end
            end
            U(isnan(U)) = 0;
            for iPlot = 1:nSVDs
                subplot(nRows, nColumns, iPlot)
                zIdx = find(obj.zAxis >= obj.boundingBox.z(1) & obj.zAxis <= obj.boundingBox.z(2));
                xIdx = find(obj.xAxis >= obj.boundingBox.x(1) & obj.xAxis <= obj.boundingBox.x(2));
                imagesc(obj.xAxis(xIdx), obj.zAxis(zIdx), U(:, :, iSVD(iPlot)));
                clim = prctile(reshape(U(:, :, iSVD(iPlot)), [], 1), [1 99]);
                % make clim symmetric around 0
                clim = [-1 1]*max(abs(clim));
                caxis(clim);
                title(sprintf('i = %1.0f, s = %3.1d', iSVD(iPlot), sVals(iPlot)));
                axis equal tight off;
            end
        end
        
        function regDoppler(obj)
            oneBigDopplerMovie = cell2mat(reshape({obj.fusi.doppler}, 1, 1, []));
            [nz, nx, nt] = size(oneBigDopplerMovie);
            fprintf('Total %g frames\n', nt);
            nSVDs = 200; % for initial svd denoising pre-registration
            nIter = 25; % number of iterations for Displacement Field estimation
            AFS = 1; % 'Accumulated Field Smoothing' parameter
            nSVDsFinal = 500; % for final decomposition
            if isfield(obj.svd, 'U') && (size(obj.svd.U, 3) >= nSVDs)
                fprintf('We already have first %g SVDs, let''s use them\n', nSVDs)
                U = obj.svd.U(:,:,1:nSVDs);
                U = reshape(U, [], nSVDs);
                S = diag(obj.svd.S(1:nSVDs));
                tmp = [obj.fusi.svd];
                V = cell2mat(reshape({tmp.V}, [], 1));
                V = V(:, 1:nSVDs);
                meanFrame = obj.svd.meanFrame;
                clear tmp;
            else
                fprintf('Let''s extract first %g SVDs ..', nSVDs)
                svdTic = tic;
                meanFrame = median(oneBigDopplerMovie, 3);
                oneBigDopplerMovie = bsxfun(@minus, oneBigDopplerMovie, meanFrame);
                [U, S, V] = nanSVD(oneBigDopplerMovie, nSVDs);
                clear oneBigDopplerMovie;
                fprintf('. done (%1.0f seconds)\n', toc(svdTic));
            end
            
            fprintf('Reconstructing Doppler movie from first %g SVDs ..', nSVDs);
            reconstructTic = tic;
            svdDoppler = U * S * V';
            svdDoppler = reshape(svdDoppler, nz, nx, nt);
            meanFrame(isnan(meanFrame)) = 0;
            svdDoppler(isnan(svdDoppler)) = 0;
            svdDoppler = bsxfun(@plus, svdDoppler, meanFrame);
            fprintf('. done (%4.2f seconds)\n', toc(reconstructTic));
            
            fprintf('Calculating displacement fields and registering Doppler data: \n')
            svdMeanFrame = median(svdDoppler, 3);
            regDoppler = zeros(size(svdDoppler), 'single');
            D = zeros(nz, nx, 2, nt, 'single');
            doppler = cell2mat(reshape({obj.fusi.doppler}, 1, 1, []));
            doppler(isnan(doppler)) = 0;
            nChar = 0;
            baseline = min(min(svdDoppler(:)), min(svdMeanFrame(:)));
            svdDoppler = log(svdDoppler - baseline + eps('single'));
            svdMeanFrame = log(svdMeanFrame - baseline + eps('single'));
            regTic = tic;
            for iFrame = 1:nt
                fprintf(repmat('\b', 1, nChar));
                minLeft = toc(regTic)/(iFrame-1)*(nt-iFrame+1)/60;
                if isfinite(minLeft)
                    endTime = datestr(now + minLeft/60/24, 'HH:MM:SS');
                else
                    endTime = datestr(now, 'HH:MM:SS');
                end
                nChar = fprintf('Registering frame %g/%g (%3.1f minutes left [%s]) ..', ...
                    iFrame, nt, minLeft, endTime);
                DF = imregdemons(svdDoppler(:,:,iFrame), svdMeanFrame, nIter, ...
                    'AccumulatedFieldSmoothing', AFS, 'DisplayWaitbar', false);
                regDoppler(:,:,iFrame) = imwarp(doppler(:,:,iFrame), DF, 'linear', 'FillValues', NaN);
                D(:, :, :, iFrame) = DF;
            end
            regDoppler(repmat(any(isnan(regDoppler), 3), 1, 1, nt)) = NaN;
            fprintf('. done (%3.1f minutes)\n', toc(regTic)/60);
            
            fprintf('Dividing registered data into separate experiments ..');
            divTic = tic;
            nFusi = length(obj.fusi);
            nFrames = cellfun(@size, {obj.fusi.doppler}, repmat({3}, 1, nFusi));
            endIdx = cumsum(nFrames);
            startIdx = [1, endIdx(1:nFusi-1)+1];
            for iFus = 1:nFusi
                idx = startIdx(iFus):endIdx(iFus);
                obj.fusi(iFus).regDoppler = regDoppler(:,:,idx);
                % apply the same mask as for the original doppler
                obj.fusi(iFus).regDoppler(isnan(obj.fusi(iFus).doppler)) = NaN;
                obj.fusi(iFus).D = D(:, :, :, idx);
            end
            obj.regParams.nSVDs = nSVDs;
            obj.regParams.nIter = nIter;
            obj.regParams.AFS = AFS;
            fprintf('. done (%3.1f seconds)\n', toc(divTic));
            
            if ~isempty(obj.svd.U)
                nSVDs = size(obj.svd.U, 3);
            else
                nSVDs = nSVDsFinal;
            end
            
            fprintf('Performing SVD decomposition on registered data (%g SVDs) ..', nSVDs);
            svdTic = tic;
            obj.svdDecomposition(nSVDs, 1);
            fprintf('. done (%3.1f seconds)\n', toc(svdTic));
            
            fprintf('Rotating SVD decomposition of dI/I of registered data (%g SVDs) ..', nSVDs);
            svdTic = tic;
            obj.svddII(1);
            fprintf('. done (%3.1f seconds)\n', toc(svdTic));
        end
        
        function rotateUdII(obj, reg)
            if reg
                U = obj.svdReg.UdII;
                S = obj.svdReg.S;
            else
                U = obj.svd.UdII;
                S = obj.svd.S;
            end
            V = [];
            for iFus = 1:length(obj.fusi)
                if reg
                    V = cat(1, V, obj.fusi(iFus).svdReg.V);
                else
                    V = cat(1, V, obj.fusi(iFus).svd.V);
                end
            end
            [nz, nx, nSVDs] = size(U);
            Uflat = reshape(U, nz*nx, nSVDs);
            mov = Uflat * diag(S) * V';
            mov = reshape(mov, nz, nx, []);
            [Unew, Snew, Vnew] = nanSVD(mov, nSVDs);
            if reg
                obj.svdReg.UdII = reshape(Unew, nz, nx, nSVDs);
                obj.svdReg.SdII = diag(Snew);
            else
                obj.svd.UdII = reshape(Unew, nz, nx, nSVDs);
                obj.svd.SdII = diag(Snew);
            end
            nFusi = length(obj.fusi);
            nFrames = cellfun(@size, {obj.fusi.doppler}, repmat({3}, 1, nFusi));
            endIdx = cumsum(nFrames);
            startIdx = [1, endIdx(1:nFusi-1)+1];
            for iFus = 1:nFusi
                idx = startIdx(iFus):endIdx(iFus);
                if reg
                    obj.fusi(iFus).svdReg.VdII = Vnew(idx, :);
                else
                    obj.fusi(iFus).svd.VdII = Vnew(idx, :);
                end
            end
        end
        
        function processFastDoppler(obj)
            % register fast doppler
            nFusi = length(obj.fusi);
            for iFus = 1:nFusi
                fprintf('Registering fus #%1.0f/%1.0f\n', iFus, nFusi);
                obj.fusi(iFus).regFastDoppler;
            end
            % calculate fast dII from registered 
            % project fast dII on svdReg.UdII
        end
        
        function saveLite(obj, filename)
            % remove raw doppler (fast + slow)
            % remove dII (fast + slow)
            % remove displacement fields
            % save with a filename provided, avoid overwriting
        end
        
    end
end
