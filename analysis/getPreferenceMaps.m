function maps = getPreferenceMaps(mov, frameTimes, stimTimes, p)

[nStims, nRepeats] = size(stimTimes);
[nz, nx, nt] = size(mov);
movSVD = rmSVD(mov, 1);
movFlat = permute(reshape(movSVD, nz*nx, nt), [2, 1]);

%%
phase = cell(nStims, 1);
amp = cell(nStims, 1);
for iStim = 1:nStims
    freqData = nan(nRepeats, nz*nx);
    for iRepeat = 1:nRepeats
        tStart = stimTimes{iStim, iRepeat}(1);
        tEnd = stimTimes{iStim, iRepeat}(2);
        frameIdx = frameTimes>=tStart & frameTimes<=tEnd;
        % get an extra frame before and after the time segment, for interpolation
        frameRange = find(frameIdx, 1, 'first') - 1 : find(frameIdx, 1, 'last') + 1;
        frameRange = frameRange(frameRange > 0 & frameRange<=length(frameTimes));
        nPoints = sum(frameIdx);
        
        % analysis including interpolation before fft
        
%         tAxis = linspace(tStart, tEnd, nPoints+1);
%         % we need to cut the last sample, so that the required frequency
%         % will be exactly the nCycles+1 sample of the Fourier transform
%         tAxis = tAxis(1:end-1);
%         snippet = interp1(frameTimes(frameRange), movFlat(frameRange, :), tAxis, 'spline', 'extrap');
%         snippetF = fft(snippet);
%         % get the information about the frequency of interest
%         freqData(iRepeat, :) = snippetF(p(iStim).nCycles+1, :);
%         % normalize by the overall power of the signal
%         ownMag = abs(freqData(iRepeat, :));
%         relPower = ownMag.^2./sum(abs(snippetF).^2);
%         freqData(iRepeat, :) = freqData(iRepeat, :)./ownMag.*relPower;
        
        % analysis without interpolation - 'direct' calculation of the fft
        % of the single frequency of interest
        tAxis = frameTimes(frameRange) - tStart;
        tAxis = tAxis(:)';
        f = 1/p(iStim).cycleDuration;
        freqData(iRepeat, :) = (cos(2*pi*f*tAxis) - 1i*sin(2*pi*f*tAxis))*movFlat(frameRange, :);
        ownMag = abs(freqData(iRepeat, :));
        relPower = ownMag.^2./sum(abs(movFlat(frameRange, :)).^2)/nPoints;
        freqData(iRepeat, :) = freqData(iRepeat, :)./ownMag.*relPower;
        
    end
    meanFreqData = reshape(mean(freqData), nz, nx);
    % slight filtering in the complex domain before averaging across repeats
    meanFreqData = imgaussfilt(real(meanFreqData)) + 1i*imgaussfilt(imag(meanFreqData));
    phase{iStim} = -angle(meanFreqData); % we take negative, easier to think about it as a delay
    amp{iStim} = abs(meanFreqData);
end

%% Calculating hemodynamic delay and preferred phase from individual phases

xposStims = find(ismember({p.orientation}, 'xpos'));
maps.xpos.hemoPhase = mod(phase{xposStims(1)}+phase{xposStims(2)}, 2*pi)/2;
maps.xpos.prefPhase = mod(phase{xposStims(1)}-maps.xpos.hemoPhase, 2*pi) + ...
    2*pi -mod(phase{xposStims(2)}-maps.xpos.hemoPhase, 2*pi);
maps.xpos.prefPhase = maps.xpos.prefPhase/2;
maps.xpos.amplitude = amp{xposStims(1)}+amp{xposStims(1)};
maps.xpos.fovAngles = p(xposStims(1)).startEndPos;

yposStims = find(ismember({p.orientation}, 'ypos'));
maps.ypos.hemoPhase = mod(phase{yposStims(1)}+phase{yposStims(2)}, 2*pi)/2;
maps.ypos.prefPhase = mod(phase{yposStims(1)}-maps.ypos.hemoPhase, 2*pi) + ...
    2*pi -mod(phase{yposStims(2)}-maps.ypos.hemoPhase, 2*pi);
maps.ypos.prefPhase = maps.ypos.prefPhase/2;
maps.ypos.amplitude = amp{yposStims(1)}+amp{yposStims(1)};
maps.ypos.fovAngles = p(yposStims(1)).startEndPos;

