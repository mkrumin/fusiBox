function saveCurrentBF(obj, po)

iFrame = obj.fusIndex;

rootFolderName = obj.folderFullData;
p = dat.paths;
localFolder = dat.expPath(obj.experimentName, 'main', 'local');
folderName = strrep(localFolder, p.localRepository, rootFolderName);
fileName = sprintf('%s_BF_%06.0f.mat', obj.experimentName, iFrame);
fileNameFilt = sprintf('%s_BFfilt_%06.0f.mat', obj.experimentName, iFrame);

if ~exist(folderName, 'dir')
    [mkSuccess, message] = mkdir(folderName);
    if mkSuccess
        fprintf('%s folder successfully created\n', folderName);
    else
        error('There was a problem creating %s. %s\n', folderName, message');
    end
end

fullFileName = fullfile(folderName, fileName);
fullFileNameFilt = fullfile(folderName, fileNameFilt);
if po.saveBF
    ind = mod(iFrame-1, 2)+1; 
    BF = obj.BF{ind};
    save(fullFileName, 'BF', '-v6')
end
if po.saveBFFilt
%     BFFilt = abs(obj.BFfilt);
%     [fid, errm] = fopen([fullFileNameFilt, '.dat'], 'w');
%     fwrite(fid, BFFilt, 'single');
%     fclose(fid);
    BFFilt = obj.BFfilt;
    save(fullFileNameFilt, 'BFFilt', '-v6');
end
