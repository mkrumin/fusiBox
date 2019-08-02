function structOut = makeStruct(varIn)

if isobject(varIn)
    sz = size(varIn);
    nObj = numel(varIn);
    structOut = struct();
    pr = properties(varIn);
    nPrs = length(pr);
    for iObj = 1:nObj
        for iPr = 1:nPrs
            try
                structOut(iObj).(pr{iPr}) = makeStruct(varIn(iObj).(pr{iPr}));
            catch
                structOut(iObj).(pr{iPr}) = [];
            end
        end
    end
    structOut = reshape(structOut, sz);
    
elseif isstruct(varIn)
    sz = size(varIn);
    nStr = numel(varIn);
    structOut = struct;
    fNames = fieldnames(varIn);
    nFs = length(fNames);
    for iStr = 1:nStr
        for iF = 1:nFs
            try
                structOut(iStr).(fNames{iF}) = makeStruct(varIn(iStr).(fNames{iF}));
            catch
                structOut(iStr).(fNames{iF}) = [];
            end
        end
    end
    structOut = reshape(structOut, sz);
else
    structOut = varIn;
end

end
