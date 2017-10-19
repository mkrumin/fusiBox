function dp = getDoppler(ExpRef)

fileName = sprintf('%s_fus.mat', ExpRef);
localPath = dat.expPath(ExpRef, 'main', 'local');
localFile = fullfile(localPath, 'fus', fileName);
if exist(localFile, 'file')
    d = load(localFile);
    dp = d.doppler;
else
    remotePath = dat.expPath(ExpRef, 'main', 'master');
    remoteFile = fullfile(remotePath, 'fus', fileName);
    if exist(remoteFile, 'file')
        d = load(remoteFile);
        dp = d.doppler;
    else
        fprintf('Cannot find Doppler data file %s\n', remoteFile);
        dp = [];
    end
end