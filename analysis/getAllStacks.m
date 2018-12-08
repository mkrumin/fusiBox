function stackList = getAllStacks(animalName)

% This function will extract a list of all y-stacks for a specific animal
% from the server
% animalName - name of the animal (string)
% stackList - cell array of corresponding ExpRefs

% get list of all experiments from the server
expList = dat.listExps(animalName);
nExps = length(expList);

isStack = false(nExps, 1);
for iExp = 1:nExps
    % for each experiment, check if it was a fUSi Y-Stack (based on the filename)
    folderName = dat.expPath(expList{iExp}, 'main', 'master');
    fileName = [expList{iExp}, '_fUSiYStack.mat'];
    isStack(iExp) = isfile(fullfile(folderName, fileName));
end

stackList = expList(isStack);