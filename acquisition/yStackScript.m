% start the main fUSi GUI (to get the SCAN object)
% initScan308;
addpath('C:\fusimodule\V19.4b');
initScan307;
%%
addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');

fUSiListener;

%% 
animalName = 'NP';
yy = 0:0.5:3.5;

%% This is for older slow fUSi
acquireYStack_old(animalName, yy, SCAN, motorObj);

%% This is for Fast fUSi
% acquireYStack(animalName, yy, SCAN, motorObj);
