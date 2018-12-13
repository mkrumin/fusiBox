function [Fmean, Fall] = showSTAMovies(sta, expData)

figPos = [10, 100, 1830 430];
pauseDur = 0.001;
nStims = length(sta.snipMean);
[nZ, nX, nT, nRepeats] = size(sta.snipAll{1});
dz = mean(diff(expData.doppler.zAxis));
dx = mean(diff(expData.doppler.xAxis));
zAxis = dz*(0:nZ-1);
xAxis = dx*(1:nX);
xAxis = xAxis - mean(xAxis);

% a little bit of preprocessing
mm = nan(nStims, 2);
for iStim = 1:nStims
    data{iStim} = sta.snipMean{iStim};
    data{iStim} = bsxfun(@minus, data{iStim}, mean(data{iStim}(:,:,sta.t<0.0), 3));
    data{iStim} = imgaussfilt(data{iStim}, [1,1]);
    %     data{iStim} = imgaussfilt(data{iStim}, [1,1])./imgaussfilt(sta.snipStd{iStim}, [1,1]);
    % data{iStim} = data{iStim} - min(data{iStim}(:)) + 1;
    % data{iStim} = log(data{iStim});
    mm(iStim, :) = prctile(data{iStim}(:), [5 99]);
end
mm = repmat([min(mm(:,1)), max(mm(:,2))], nStims, 1);

% nRows = floor(sqrt(nStims));
% nColumns = ceil(nStims/nRows);
nRows = 2;
nColumns = nStims;
% showing the movies

hFig = figure('Position', figPos);
Fmean = [];
for iFrame = 1:nT
    for iStim = 1:nStims
        if iFrame == 1
            ax = subplot(nRows, nColumns, iStim);
            imTxtr(iStim) = imagesc(ax, sta.stimMean{iStim}(:,:,iFrame));
            colormap(ax, 'gray');
            caxis(ax, [-1 1]);
            axis equal tight off;
            if iStim == 1
                hTit = title(ax, sprintf('%3.1f [s]', sta.t(iFrame)), 'FontSize', 14);
            end
            
            ax = subplot(nRows, nColumns, nStims + iStim);
            im(iStim) = imagesc(xAxis, zAxis, data{iStim}(:, :, iFrame));
            colormap(ax, 'hot');
            caxis(ax, mm(iStim, :));
            %             caxis(ax, [0 mm(iStim, 2)]);
            colorbar;
            axis equal tight;
            if iStim == 1
                xlabel('ML [mm]');
                ylabel('DV [mm]');
            end
            if iStim == nStims
                hT = text(ax, max(xlim(ax)) + 3, 3, '\DeltaI/I_0 [%]');
                hT.Rotation = 90;
                hT.HorizontalAlignment = 'Center';
                hT.VerticalAlignment = 'Top';
                hT.FontSize = 12;
                hT.FontWeight = 'bold';
            end
            ax.FontSize = 12;
        else
            im(iStim).CData = data{iStim}(:, :, iFrame);
            imTxtr(iStim).CData = sta.stimMean{iStim}(:,:,iFrame);
        end
        hTit.String = sprintf('%3.1f [s]', sta.t(iFrame));
    end
    drawnow;
    pause(pauseDur);
    if iFrame == 1
        Fmean = getframe(hFig);
    else
        Fmean(iFrame) = getframe(hFig);
    end
end

%%
% figure('Position', figPos);

tmp = cell2mat(sta.snipAll);
mm = prctile(tmp(:), [5 99.5]);
% mm(1) = 0;

for iRepeat = 1:nRepeats
    for iFrame = 1:nT
        for iStim = 1:nStims
            if iFrame == 1 && iRepeat == 1
                ax = subplot(nRows, nColumns, iStim);
                imTxtr(iStim) = imagesc(ax, sta.stimAll{iStim}(:,:,iFrame, iRepeat));
                colormap(ax, 'gray');
                caxis(ax, [-1 1]);
                axis equal tight off;
                if iStim == 1
                    hTit = title(ax, sprintf('(%1.0f/%1.0f) %3.1f [s]', iRepeat, nRepeats, sta.t(iFrame)),...
                        'FontSize', 14);
                end
                
                ax = subplot(nRows, nColumns, nStims + iStim);
                im(iStim) = imagesc(xAxis, zAxis, sta.snipAll{iStim}(:, :, iFrame, iRepeat));
                colormap(ax, 'hot');
                caxis(ax, mm);
                colorbar;
                axis equal tight;
                if iStim == 1
                    xlabel('ML [mm]');
                    ylabel('DV [mm]');
                end
                if iStim == nStims
                    hT = text(ax, max(xlim(ax)) + 3, 3, '\DeltaI/I_0 [%]');
                    hT.Rotation = 90;
                    hT.HorizontalAlignment = 'Center';
                    hT.VerticalAlignment = 'Top';
                    hT.FontSize = 12;
                    hT.FontWeight = 'bold';
                end
                ax.FontSize = 12;
            else
                im(iStim).CData = sta.snipAll{iStim}(:, :, iFrame, iRepeat);
                imTxtr(iStim).CData = sta.stimAll{iStim}(:, :, iFrame, iRepeat);
            end
            hTit.String = sprintf('(%1.0f/%1.0f) %3.1f [s]', iRepeat, nRepeats, sta.t(iFrame));
        end
        drawnow;
        pause(pauseDur);
        if iFrame == 1 & iRepeat == 1
            Fall = getframe(hFig);
        else
            Fall(end+1) = getframe(hFig);
        end
    end
end

