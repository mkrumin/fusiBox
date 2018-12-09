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
            obj.Doppler = squeeze(median(data.Doppler.yStack, 3));
            obj.BMode = data.BMode;
            obj.BMode.yStack = squeeze(obj.BMode.yStack);
            obj.BMode.yAxis = data.yCoords;
        end
        
        function plotVolume(obj)
            [X, Y, Z] = meshgrid(obj.xAxis, obj.yAxis, obj.zAxis);
            % we need to make the first dimension to be Y, second - X, and third - Z
            stack = permute(obj.Doppler, [3 2 1]);
            stack = -stack.^(1/2);
            dX = diff(obj.xAxis(1:2));
            dY = diff(obj.yAxis(1:2));
            dZ = diff(obj.zAxis(1:2));
            stack = imgaussfilt3(stack, 0.05./[dX, dY, dZ]);
            alphaPower = 4;
            hFig = figure;
            
            ax = subplot(1, 1, 1);
            hSlice = slice(X, Y, Z, stack, obj.xAxis, obj.yAxis, obj.zAxis, 'linear');
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
                    ind = find(obj.xAxis == hSlice(i).XData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(:, ind, :).^alphaPower);
                elseif (max(hSlice(i).YData(:)) - min(hSlice(i).YData(:))) == 0
                    ind = find(obj.yAxis == hSlice(i).YData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(ind, :, :).^alphaPower);
                elseif (max(hSlice(i).ZData(:)) - min(hSlice(i).ZData(:))) == 0
                    ind = find(obj.zAxis == hSlice(i).ZData(1));
                    hSlice(i).AlphaData = squeeze(alphaVal(:, :, ind).^alphaPower);
                end
            end
            
            ax.DataAspectRatio = [1 1 1];
            ax.CameraViewAngle = 9;
            ax.ZDir = 'reverse';
            ax.XLim = [3, 9.8];
            ax.ZLim = [0.6, 6];
            view(ax, -30, 20);
            ax.XLabel.String = 'ML [mm]';
            ax.YLabel.String = 'AP [mm]';
            ax.ZLabel.String = 'DV [mm]';
            title(ax, strrep(obj.ExpRef, '_', '\_'));
            
        end
    end
end
