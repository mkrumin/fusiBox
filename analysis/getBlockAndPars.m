function [blk, p] = getBlockAndPars(ExpRef)

dBlock = dat.expFilePath(ExpRef, 'block', 'master');
if exist(dBlock, 'file')
    load(dBlock)
    blk = block;
end

dPars = dat.expFilePath(ExpRef, 'parameters', 'master');
if exist(dPars, 'file')
    load(dPars)
    p = parameters;
end

