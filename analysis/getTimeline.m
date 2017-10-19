function Timeline = getTimeline(ExpRef)

fileLocal = dat.expFilePath(ExpRef, 'timeline', 'local');
if exist(fileLocal, 'file')
    load(fileLocal);
else
    fileRemote = dat.expFilePath(ExpRef, 'timeline', 'master');
    if exist(fileRemote, 'file')
        load(fileRemote);   
    else
        fprintf('Timeline file %s does not exist\n');
        Timeline = [];
    end
end