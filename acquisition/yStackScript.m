addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');
%%
% start the main fUSi GUI (to get the SCAN object)
initScan308;

%%
animalName = 'CR01';
yy = 0:0.1:5;
%%
acquireYStack(animalName, yy, SCAN, motorObj);