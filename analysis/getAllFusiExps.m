function expSummary = getAllFusiExps(animalName)

% This function will extract a list of all y-stacks for a specific animal
% from the server
% animalName - name of the animal (string)
% stackList - cell array of corresponding ExpRefs

% get list of all experiments from the server
[expList, dateList, ~]= dat.listExps(animalName);
nExps = length(expList);

isStack = false(nExps, 1);
isFus = false(nExps, 1);
for iExp = 1:nExps
    % for each experiment, check if it was a fUSi Y-Stack (based on the filename)
    folderName = dat.expPath(expList{iExp}, 'main', 'master');
    stackFileName = [expList{iExp}, '_fUSiYStack.mat'];
    isStack(iExp) = isfile(fullfile(folderName, stackFileName));
    fusFileName = [expList{iExp}, '_fus.mat'];
    isFus(iExp) = isfile(fullfile(folderName, fusFileName));
end

stackList = expList(isStack);
fusList = expList(isFus);
stackDates = dateList(isStack);
fusDates = dateList(isFus);

for iStack = 1:length(stackList)
    expSummary(iStack).expDate = stackDates(iStack);
    expSummary(iStack).stackRef = stackList{iStack};
    expSummary(iStack).fusRef = fusList(ismember(fusDates, stackDates(iStack)));
    
    % also figure out if it was mc/mpep experiment and load
    % parameters/block file
    [expNums, blocks, hasBlock, pars, isMpep, ~, hasTimeline] = ...
        dat.whichExpNums(animalName, expSummary(iStack).expDate);
    expRefs = dat.constructExpRef(animalName, expSummary(iStack).expDate, expNums);
    [~, ia, ib] = intersect(expSummary(iStack).fusRef, expRefs);
    idx = ib(ia);
    expSummary(iStack).isMpep = isMpep(idx)';
    expSummary(iStack).isMC = hasBlock(idx)';
    expSummary(iStack).hasTL = hasTimeline(idx)';
    blocks(~hasBlock) = {[]}; % make sure blocks is long enough
    expSummary(iStack).block = blocks(idx)';
    expSummary(iStack).pars = pars(idx)';
    expSummary(iStack).expDef = cell(length(expSummary(iStack).isMpep), 1);
    for iExp = 1:length(expSummary(iStack).isMpep)
        if expSummary(iStack).isMpep(iExp)
            expSummary(iStack).expDef{iExp} = expSummary(iStack).pars{iExp}.Protocol.xfile;
        else
            [~, expSummary(iStack).expDef{iExp}] = fileparts(expSummary(iStack).pars{iExp}.defFunction);
        end
    end
end
