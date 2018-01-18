addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');
%%
% start the main fUSi GUI (to get the SCAN object)
initScan308;

%%
animalName = 'default';
yy = 0:0.1:4;
%%
acquireYStack(animalName, yy, SCAN, motorObj);