function setDummyPaths(obj)

filePath = 'D:\junk\';
obj.animalName = 'junk';
obj.experimentName = 'junk';
% obj.animalName = info.subject;
% obj.experimentName = info.expRef;
obj.animal = filePath;
obj.images = filePath;
obj.info = filePath;
obj.fus = filePath;
obj.fulldata = filePath;
obj.fileJournal = fullfile(filePath, 'junk.txt');
[mkSuccess, message] = mkdir(filePath);
if mkSuccess
    fprintf('Dummy %s folder successfully created\n', filePath);
else
    error('There was a problem creating %s. %s\n', filePath, message');
end
