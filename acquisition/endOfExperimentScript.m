animalName = 'CR019';
expDate = '2019-11-18';

question = sprintf('Process data of %s for %s?', animalName, expDate);
button = questdlg(question,'fUSi post exp script','OK','Cancel','Cancel');
if isequal(button, 'Cancel')
    % abort
    return;
else
    % otherwise continue
end

%% get list of experiments for the date

p = dat.paths;
localFolderName = fullfile(p.localRepository, animalName, expDate);
subfolders = dir(localFolderName);
subfolders = subfolders([subfolders.isdir]);
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));

ExpRefs = cell(0);
ExpRefsStr = '';
for iSub = 1:length(subfolders)
    % detect all the '_fus.mat' files and extract the ExpRef
    files = dir(fullfile(localFolderName, subfolders(iSub).name, '*_fus.mat'));
    for iFile = 1:length(files)
        ExpRefs{end+1} = strrep(files(iFile).name, '_fus.mat', '');
        ExpRefsStr = cat(2, ExpRefsStr, [ExpRefs{end}, char(10)]);
    end
end

question = sprintf('Will be processing the following experiments:\n%s', ExpRefsStr);
button = questdlg(question,'fUSi post exp script','OK','Cancel','Cancel');
if isequal(button, 'Cancel')
    % abort
    return;
else
    % otherwise continue
end


%% create a local backup copy of the data
tic;
localBackupFolderName = fullfile(p.localRepository, animalName, [expDate, '_bkp']);
fprintf('Creating local backup copy ..');
[st, msg, msgID] = copyfile(localFolderName, localBackupFolderName);
if st
    fprintf('. success!\n')
    fprintf('Folder %s created\n', localBackupFolderName);
    toc;
else
    fprintf('. fail!\n')
    fprintf('Error message: %s\n', msg);
    fprintf('Error message ID: %s\n', msgID);
    fprintf('Canceling the whole thing ... \n');
    return;
end
%% bin full beam-formed data
tStart = tic;
for iExp = 1:length(ExpRefs)
    binBF(ExpRefs{iExp});
end
fprintf('\nTotal time taken to bin BF: %1.0f seconds\n\n', toc(tStart));

%% copy files to server
serverFolderName = fullfile(p.mainRepository, animalName, expDate);
fprintf('Copying the data to the server (%s) ..', serverFolderName);
tic;
[st, msg, msgID] = copyfile(localFolderName, serverFolderName);
if st
    fprintf('. success!\n')
    fprintf('Data successfully copied to %s\n', serverFolderName);
    toc;
else
    fprintf('. fail!\n')
    fprintf('There was some issue copying the data to the server:\n');
    fprintf('Error message: %s\n', msg);
    fprintf('Error message ID: %s\n', msgID);
    return;
end

%% move fullData files to 'processed' folder

[folderName, fileStem] = dat.expPath(ExpRefs{1}, 'main', 'local');
folderName = strrep(folderName, localFolderName, localBackupFolderName);
fileName = sprintf('%s_fus.mat', fileStem);
fullFileName = fullfile(folderName, fileName);
d = load(fullFileName);
folderFullData = d.doppler.params.folderFullData;


fullDataFolderName = fullfile(folderFullData, animalName, expDate);
processedFolderName = strrep(fullDataFolderName, folderFullData, fullfile(folderFullData, 'Processed'));

fprintf('Moving full processed data to %s ..', processedFolderName);

tic;
[st, msg, msgID] = movefile(fullDataFolderName, processedFolderName);

if st
    fprintf('. success!\n')
    fprintf('Data successfully moved to %s\n', processedFolderName);
    toc;
else
    fprintf('. fail!\n')
    fprintf('There was some issue moving the data :\n');
    fprintf('Error message: %s\n', msg);
    fprintf('Error message ID: %s\n', msgID);
    return;
end


