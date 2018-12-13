classdef YStack < handle
    
    
    properties
        ExpRef = '';
        xAxis = [];
        zAxis = [];
        yAxis = [];
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
        end
        
        function hFig = plotVolume(obj)
            xLimits = [2.4, 10.4];
            zLimits = [0.2, 5.9];
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
%             ax.XLim = xLimits;
%             ax.ZLim = zLimits;
            view(ax, -30, 20);
            ax.XLabel.String = 'ML [mm]';
            ax.YLabel.String = 'AP [mm]';
            ax.ZLabel.String = 'DV [mm]';
            title(ax, strrep(obj.ExpRef, '_', '\_'));
            
        end
        
        function plotSlices(obj, sliceIdx)
            if nargin < 2
                nSlices = length(obj.yAxis);
                sliceIdx = 1:length(obj.yAxis);
            else
                nSlices = length(sliceIdx);
            end
            nRows = floor(sqrt(nSlices));
            nColumns = ceil(nSlices/nRows);
            
            xIdx = obj.xAxis >= 2.4 & obj.xAxis <= 10.4;
            xx = obj.xAxis(xIdx);
            xx = xx - mean(xx);
            zIdx = obj.zAxis>=0.2 & obj.zAxis<=5.9;
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
                title(obj.yAxis(sliceIdx(iSlice)))
                ax.Position = ax.Position + [-0.01 -0.01 0.02 0.02];
                ax.FontSize = 14;
            end
        end
    end
end
