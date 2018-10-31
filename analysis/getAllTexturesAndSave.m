function getAllTexturesAndSave(animalName, expDate, expList)

% this function will recover all the textures used in the mpep experiment
% for specific animal on a specific day, and save them to the server

if nargin < 1
    % use this for testing
%     animalName = 'CR011';
%     expDate = '2018-10-24';
%     expList = [3, 10, 11];
end


[ExpRefs, expDatenums, exps] = dat.listExps(animalName);
idx = expDatenums == datenum(expDate) & ismember(exps, expList);

ExpRefs = ExpRefs(idx);
%%
for iExp = 1:length(ExpRefs)
    try
        p = getMpepProtocol(ExpRefs{iExp});
        fprintf('Extracted %s protocol... ', ExpRefs{iExp});
        hwInfo = getHardwareInfo(ExpRefs{iExp});
        hwInfo.windowPtr = NaN;
        stim = getStimTextures(hwInfo, p.pars, p.xfile);
        fprintf('and textures (from %s)\n', p.xfile);
        folderName = dat.expPath(ExpRefs{iExp}, 'main', 'master');
        fileName = sprintf('%s_stimTextures.mat', ExpRefs{iExp});
        save(fullfile(folderName, fileName), 'stim')
        fprintf('Saved to %s\n', fullfile(folderName, fileName));
    catch e
        fprintf('\n%s\n', e.message)
        fprintf('It looks like %s is not an mpep experiment\n', ExpRefs{iExp});
        continue;
    end
end
