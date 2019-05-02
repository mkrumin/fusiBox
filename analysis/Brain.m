classdef Brain < handle
    
    properties
        animalName = '';
        yStacks;
        xAxis = [];
        zAxis = [];
        yAxis = [];
    end
    
    methods
        function obj = Brain(name)
            obj.animalName = name;
            stackRefs = getAllStacks(obj.animalName);
            for iStack = 1:length(stackRefs)
                yStacks(iStack) = YStack(stackRefs{iStack});
            end
            obj.yStacks = yStacks;
            
        end
    end
    
end