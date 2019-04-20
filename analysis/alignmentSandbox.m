animalName = 'PC036';

br = Brain(animalName);

nStacks = length(br.yStacks);
%%
for iStack = 1:nStacks
    br.yStacks(iStack).autoCrop(true);
end

%%

alignStacks(br.yStacks(3), br.yStacks(6));