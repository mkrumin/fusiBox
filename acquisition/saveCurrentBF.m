function saveCurrentBF(obj)

iFrame = obj.fusIndex;
% timeStamp = obj.time(iFrame+2);

folderName = obj.fulldata;
fileName = sprintf('%s_BF_%06.0f.mat', obj.experimentName, iFrame);
fileNameFilt = sprintf('%s_BFfilt_%06.0f.mat', obj.experimentName, iFrame);

fullFileName = fullfile(folderName, fileName);
fullFileNameFilt = fullfile(folderName, fileNameFilt);
BF = obj.BF;
save(fullFileName, 'BF', '-v6')
BFFilt = obj.BFfilt;
save(fullFileNameFilt, 'BFFilt', '-v6');
