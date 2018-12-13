animalName = 'CR013_DRI2';

stacksList = getAllStacks(animalName);
nStacks = length(stacksList);
clear st;
for iStack = 1:nStacks
    st(iStack) = YStack(stacksList{iStack});
end

%%
for iStack = 1:nStacks
    st(iStack).plotVolume;
    st(iStack).plotSlices;
end

%%
    