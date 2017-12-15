addpath('C:\fusimodule\motorZaber');

% start the motor
motorObj = stpMotor('COM1');
%%
% start the main fUSi GUI (to get the SCAN object)
initScan307;

%%
animalName = 'CR01';
yy = 0:0.1:4;
%%
acquireYStack(animalName, yy, SCAN, motorObj);