function sta = getSTA(t, mov,dataIn)

stimTimes = dataIn.stimTimes;
[nStims, nRepeats] = size(stimTimes);
[nZ, nX, nFrames] = size(mov);

dt = 0.1; % this is the target dt after upsampling/interpolation
tPre = 3; 
tPost = 3;
stimDur  = max(cellfun(@diff, stimTimes), [], 2);
stimDur = stimDur(:)'; % make sure it is a row vector
tAxis = -tPre:dt:round(max(stimDur))+tPost;
tAxis = tAxis(:); % make sure it is a column vector
nT = length(tAxis);

mov = reshape(mov, nZ*nX, nFrames)';

snippet = cell(1, nStims);
stim = cell(1, nStims);
for iStim = 1:nStims
    snippet{iStim} = nan(nT, nZ*nX, nRepeats);
    tmpTexture = getCurrentTexture(1, dataIn.stim, dataIn.stimTimes, dataIn.stimFrameTimes, dataIn.hwInfo);
    [nr, nc] = size(tmpTexture);
    stim{iStim} = nan(nr, nc, nT, nRepeats);
    for iRepeat = 1:nRepeats
        tStart = stimTimes{iStim, iRepeat}(1);
        tt = tStart(1) + tAxis;
%         tmp = [zeros(1, size(mov, 2)); diff(interp1(t, mov, tt))];
%         tmp = max(0, tmp);
        tmp = interp1(t, mov, tt);
        snippet{iStim}(:,:,iRepeat) = tmp;
        % by definition let's say response at t == 0 is zero
%         snippet{iStim}(:,:,iRepeat) = ...
%             bsxfun(@minus, snippet{iStim}(:,:,iRepeat), snippet{iStim}(tAxis == 0, :, iRepeat));
        for iT = 1:nT
            stim{iStim}(:, :, iT, iRepeat) = ...
                getCurrentTexture(tt(iT), dataIn.stim, dataIn.stimTimes, dataIn.stimFrameTimes, dataIn.hwInfo);
        end
    end
    snipStd{iStim} = nanstd(snippet{iStim}, [], 3);
    snipMean{iStim} = nanmedian(snippet{iStim}, 3);
    snipMean{iStim} = reshape(snipMean{iStim}', nZ, nX, nT);
    snipStd{iStim} = reshape(snipStd{iStim}', nZ, nX, nT);
    snippet{iStim} = reshape(permute(snippet{iStim}, [2, 1, 3]), nZ, nX, nT, nRepeats);
    stimMean{iStim} = nanmean(stim{iStim}, 4);
end

sta.t = tAxis(:);
sta.stimOn = tAxis>0 & tAxis<stimDur;
sta.stimDur = stimDur;
sta.snipAll = snippet;
sta.snipMean = snipMean;
sta.snipStd = snipStd;
sta.stimAll = stim;
sta.stimMean = stimMean;