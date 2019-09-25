%% udp testing script

global SCAN
SCAN.folderFullData = 'Z:\fUSiFullData';
% rig=RigInfoGet;

% echoudp('on',1001)
u = udp('1.1.1.1', 1103, 'LocalPort', 1001);
try
    switch fusVersion
        case 'R07PX'
            set(u, 'DatagramReceivedFcn', @fUSiUDPCallback_R07PX);
        otherwise
            set(u, 'DatagramReceivedFcn', @fUSiUDPCallback);
    end
catch
    set(u, 'DatagramReceivedFcn', @fUSiUDPCallback);
end

u.UserData.motorObj = motorObj;
fopen(u);

fusiWorkaround(fusVersion);
% echoudp('off');

% fclose(u);
% delete(u);

% fclose(u); fopen(u);

