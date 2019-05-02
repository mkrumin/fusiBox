folderName = 'Z:\fUSiFullData\PC037\2019-04-16\5';
oldExpRef = '2019-04-16_1_PC036';
newExpRef = '2019-04-16_5_PC037';
oldPath = cd(folderName);
files = dir([oldExpRef, '*.mat']);
fprintf('Renaming (copying, actually) files..');
for iFile = 1:length(files)
    newFileName = strrep(files(iFile).name, oldExpRef, newExpRef);
    copyfile(files(iFile).name, newFileName);
end
fprintf('.done!\n')
toc;