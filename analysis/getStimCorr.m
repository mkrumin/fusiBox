function out = getStimCorr(sta)

nStims = length(sta.snipAll);
[nZ, nX, ~, nRepeats] = size(sta.snipAll{1});
rho = cell(1, nStims);
pval = cell(1, nStims);
for iStim = 1:nStims
    stimOn = sta.stimOn(:, iStim);
    stimOn = repmat(stimOn(:), nRepeats, 1);
    for iZ = 1:nZ
        for iX = 1:nX
            sig = sta.snipAll{iStim}(iZ, iX, :, :);
            sig = sig(:);
            [tmpR, tmpP] = corrcoef(stimOn(:), sig, 'Rows', 'complete');
            rho{iStim}(iZ, iX) = tmpR(2);
            pval{iStim}(iZ, iX) = tmpP(2);
        end
    end
end

out.rho = rho;
out.pval = pval;

