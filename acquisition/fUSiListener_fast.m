%% udp testing script

rig=RigInfoGet;

% hFig = fusiWorkaround;

% echoudp('on',1001)
u = udp(rig.zpepComputerIP, 1103, 'LocalPort', 1001);
set(u, 'DatagramReceivedFcn', @fUSiUDPCallback_fast);
fopen(u);

% echoudp('off');

% fclose(u);
% delete(u);

% fclose(u); fopen(u);

