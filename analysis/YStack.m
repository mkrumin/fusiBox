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
    end
    
    methods
        function obj = YStack(ExpRef)
            obj.ExpRef = ExpRef;
            data = load(fullfile(dat.expPath(ExpRef, 'main', 'master'), ...
                [ExpRef, '_fUSiYStack.mat']));
            obj.xAxis = data.Doppler.xAxis;
            obj.zAxis = data.Doppler.zAxis;
            obj.yAxis = data.yCoords;
            %             obj.Doppler = squeeze(median(data.Doppler.yStack, 3));
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
                yInd = find(obj.yAxis == round(yPos(iSlice), 1));
                zIdx = find(obj.zAxis >= obj.boundingBox.z(1) & obj.zAxis <= obj.boundingBox.z(2));
                xIdx = find(obj.xAxis >= obj.boundingBox.x(1) & obj.xAxis <= obj.boundingBox.x(2));
                im = obj.Doppler(zIdx, xIdx, yInd);
                im = sqrt(im - min(im(:)));
                figure;
                hIm = imagesc(obj.xAxis(xIdx), obj.zAxis(zIdx), im);
                axis equal tight
                colormap hot;
                caxis(prctile(im(:), [1 99]));
                xMinMax = xlim;
                zMinMax = ylim;
                xx = [xMinMax, linspace(xMinMax(2), xMinMax(1), 7)]';
                yy = [repmat(zMinMax(2), 1, 2),  repmat(zMinMax(1), 1, 7)]';
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
                obj.fusi(iFus).doppler = bsxfun(@times, obj.fusi(iFus).doppler, obj.mask(iMask).bw);
            end
        end
    end
end
