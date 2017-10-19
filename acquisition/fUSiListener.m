%% udp testing script

rig=RigInfoGet;

% echoudp('on',1001)
u = udp(rig.zpepComputerIP, 1103, 'LocalPort', 1001);
set(u, 'DatagramReceivedFcn', @fUSiUDPCallback);
fopen(u);

fusiWorkaround;
% echoudp('off');

% fclose(u);
% delete(u);

% fclose(u); fopen(u);

