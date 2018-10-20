addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');
%%
% start the main fUSi GUI (to get the SCAN object)
initScan308;

%% 
animalName = 'CR009';
yy = 0:0.1:5.3;

%% This is for older slow fUSi
acquireYStack_old(animalName, yy, SCAN, motorObj);

%% This is for Fast fUSi
acquireYStack(animalName, yy, SCAN, motorObj);
