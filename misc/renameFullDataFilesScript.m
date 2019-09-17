folderName = 'Z:\fUSiFullData\PC038\2019-06-14\4';
oldExpRef = '2019-06-14_1_PC041';
newExpRef = '2019-06-14_4_PC038';
oldPath = cd(folderName);
files = dir([oldExpRef, '*.mat']);
fprintf('Renaming (copying, actually) files..');
tic;
for iFile = 1:length(files)
    newFileName = strrep(files(iFile).name, oldExpRef, newExpRef);
    copyfile(files(iFile).name, newFileName);
end
fprintf('.done!\n')
toc;