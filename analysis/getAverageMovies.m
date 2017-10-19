function aveMov = getAverageMovies(mov, frameTimes, stimTimes, p)


nFramesPerSwipe = 15;
% calculating the number of swipes per stimulus presentation
% here we assume (for now) that all the stimuli are the same length
% we also assume that the number of swipes is an integer
[nStims, nRepeats] = size(stimTimes);

[nz, nx, nt] = size(mov);
mov = reshape(mov, nz*nx, nt);
mov = permute(mov, [2 1]); % we need time to be the first dimension
mov = medfilt1(mov, 5);

for iStim = 1:nStims
    nSwipes = p(iStim).nCycles;
    nPoints = nFramesPerSwipe*nSwipes;
    snippets = nan(nPoints, nz*nx, nRepeats);
    for iRepeat = 1:nRepeats
        tStartEnd = stimTimes{iStim, iRepeat};
        tt = linspace(tStartEnd(1), tStartEnd(2), nPoints+1);
        tt = tt(1:end-1)+diff(tt(1:2))/2;
        snippets(:,:,iRepeat) = interp1(frameTimes, mov, tt);
    end
    snippets = permute(snippets(1:nFramesPerSwipe*nSwipes, :, :), [2 1 3]);
    snippets = reshape(snippets, nz*nx, nFramesPerSwipe, []);
    % sometimes we can get NaN frames (usually on the first repeat of the
    % first stimulus, when the acquisition hasn't started yet for some
    % reason), so we use nanmean here.
    aveMov{iStim} = reshape(nanmean(snippets, 3), nz, nx, []);
end
