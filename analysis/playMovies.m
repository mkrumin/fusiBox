function playMovies(mov, pars, nLoops)

if nargin<3
    nLoops = 1;
end

nStims = length(mov);
nFrames = size(mov{1}, 3);

nRows = floor(sqrt(nStims));
nColumns = ceil(nStims/nRows);

for iStim = 1:nStims
    
    mov{iStim} = rmSVD(mov{iStim}, 1);
    mov{iStim} = imgaussfilt(mov{iStim});
    
    %     mov{iStim} = bsxfun(@minus, mov{iStim}, nanmean(mov{iStim}, 3));
    lims{iStim} = prctile(mov{iStim}(:), [1 99]);
    %     mov{iStim} = bsxfun(@rdivide, mov{iStim}+epsilon, nanmean(mov{iStim}, 3)+epsilon);
    
    t = linspace(0, pars(iStim).cycleDuration, nFrames+1);
    pos = linspace(pars(iStim).startEndPos(1), pars(iStim).startEndPos(2), nFrames+1);
    params(iStim).t = t(1:end-1) + diff(t(1:2)/2);
    params(iStim).pos = pos(1:end-1) + diff(pos(1:2)/2);
end

for iLoop = 1:nLoops
    for iFrame = 1:nFrames
        for iStim = 1:nStims
            subplot(nRows, nColumns, iStim);
            imagesc(pars(iStim).xAxis, pars(iStim).yAxis, mov{iStim}(:,:,iFrame));
            caxis(lims{iStim});
            txt = {sprintf('%4.2f s', params(iStim).t(iFrame));...
                sprintf('%4.2f\\circ', params(iStim).pos(iFrame))};
            text(max(xlim)-0.2, min(ylim)+0.2, txt,...
                'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top');
            title(sprintf('%s: %d\\circ\\rightarrow%d\\circ', pars(iStim).orientation, ...
                pars(iStim).startEndPos(1), pars(iStim).startEndPos(2)));
            colormap hot
            [iColumn, iRow] = ind2sub([nRows, nColumns], iStim);
            if iColumn == 1
                ylabel('Depth [mm]');
            end
            if iRow == nRows
                xlabel('X [mm]');
            end
            axis equal tight
        end
        drawnow;
        %     waitforbuttonpress
            pause(0.05);
    end
    pause(2);
end