classdef YStack < handle
    
    properties
        ExpRef = '';
        xAxis = [];
        zAxis = [];
        yAxis = [];
        boundingBox = struct('x', [], 'y', [], 'z', []);
        Doppler = [];
        BMode = [];
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
        end
        
        function getBoundingBox(obj)
            h = figure;
            data = max(obj.Doppler, [], 3);
            data = sqrt(data);
            imagesc(obj.xAxis, obj.zAxis, data);
            axis equal tight;
            colormap hot
            caxis(prctile(data(:), [1 99]));
            title('Draw a rectangle surrounding the brain, then double click it');
            hRect = imrect(gca);
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
        
        function hFig = plotVolume(obj)
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
            alphaPower = 2.5;
            hFig = figure('Name', obj.ExpRef);
            
            ax = subplot(1, 1, 1);
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
            view(ax, -30, 20);
            axis(ax, 'tight');
            ax.XLabel.String = 'ML [mm]';
            ax.YLabel.String = 'AP [mm]';
            ax.ZLabel.String = 'DV [mm]';
            title(ax, strrep(obj.ExpRef, '_', '\_'));
            
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
            cminmax = prctile(data(:), [0.01 99]);
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
    end
end
