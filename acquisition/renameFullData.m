function renameFullData(obj)

p = dat.paths;
sourceFolderName = obj.fileNames;
fusFolderName = obj.fus;
targetFolderName = strrep(fusFolderName, p.localRepository, obj.folderFullData);

[status, msg, ~] = movefile(sourceFolderName, targetFolderName);
if status
    fprintf('Full data moved from %s to %s successfully\n', ...
        sourceFolderName, targetFolderName)
else
    warning(sprintf(...
        'There was a problem moving the full data folder %s to %s\n', ...
        sourceFolderName, targetFolderName));
    warning(sprintf('With the following message : %s\n', msg));
    fprintf('\n\n\nMove/rename the folder manually before continuing !!!\n\n\n');
end