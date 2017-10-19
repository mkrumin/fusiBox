function saveCurrentBF(obj)

iFrame = obj.fusIndex;
timeStamp = obj.time(iFrame+2);

folderName = obj.fulldata;
fileName = sprintf('%s_BF_%06.0f.mat', obj.experimentName, iFrame);
fileNameFilt = sprintf('%s_BFfilt_%06.0f.mat', obj.experimentName, iFrame);

fullFileName = fullfile(folderName, fileName);
fullFileNameFilt = fullfile(folderName, fileNameFilt);
BF = obj.BF;
save(fullFileName, 'BF', '-v6')
BFFilt = obj.BFfilt;
save(fullFileNameFilt, 'BFFilt', '-v6');


return;
%%
figure;
guess = permute(mean(abs(obj.BFfilt).^2), [2, 3, 1]);
subplot(1, 2, 1);
imagesc(guess);
colorbar;
subplot(1, 2, 2)
imagesc(obj.I0);
colorbar
figure
imagesc(guess-obj.I0);
colorbar