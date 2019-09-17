% testing the new version

addpath('C:\fusimodule\R07PX');
myDir = cd('C:\fusimodule\R07PX');
initScan307;
cd(myDir);

setFolder('D:\testNewVersion');
setFileName('testCR015');
setParameters('parameters128.m')
setDepthCompute(5, 6)
SCAN.folderFullData = 'Z:\testNewVersion';
SCAN.fulldata = 'Z:\testNewVersion';