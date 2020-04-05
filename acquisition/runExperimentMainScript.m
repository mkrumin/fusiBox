% testing the new version

addpath('C:\fusimodule\R07PX');
myDir = cd('C:\fusimodule\R07PX');
initScan307;
cd(myDir);

%%
% make sure the folder exists before calling this function
dummyFolder = 'D:\junk';
mkSuccess = true;
if ~exist(dummyFolder, 'dir')
    [mkSuccess, mkErrMess] = mkdir(dummyFolder);
end
if mkSuccess
    setFolder(dummyFolder); %also creates subfolders (fus, fulldata, info, images)
    setFileName('test'); % sets SCAN.experimentName
    setParameters('parameters128.m')
    setDepthCompute(5, 6)
    SCAN.folderFullData = 'Z:\fUSiFullData';
    SCAN.fulldata = SCAN.folderFullData;
else
    warning(sprintf('Couldn''t create a local folder %s, with the following message:\n%s\naborting...\n', ...
        dummyFolder, mkErrMess));
end

%%
addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');
fusVersion = 'R07PX';
fUSiListener;

%% stack acquisitions
animalName = 'CR019';
yy = 0.9;

%% This is for older slow fUSi
acquireYStack_R07PX(animalName, yy, SCAN, motorObj);




