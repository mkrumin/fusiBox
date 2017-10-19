function Protocol = getMpepProtocol(ExpRef)

SetDefaultDirs;
folder = DIRS.data;
[animal, iseries, iexp] = dat.parseExpRef(ExpRef);
expDate = datestr(iseries, 'yyyy-mm-dd');
expNum = num2str(iexp);

fileName = fullfile(folder, animal, expDate, expNum, 'Protocol.mat');

p = load(fileName);
Protocol = p.Protocol;