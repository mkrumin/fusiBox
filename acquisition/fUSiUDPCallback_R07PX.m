function fUSiUDPCallback_R07PX(src, event)

% fprintf('%s:%d\n', u.DatagramAddress, u.DatagramPort),
% u.RemoteHost=u.DatagramAddress;
% u.RemotePort=u.DatagramPort;
% disp('now reading data');

% persistent folders
global SCAN

ExpStartDelay = 10;
stopDelay = 0; % delay in seconds between receiving ExpEnd and aborting (stopping) the acquisition
% The best practive is to use 0, and use the ExpEnd delay feature in mpep
% to acquire a few seconds of data after the last stimulus presentation.
% stopDelay in Timeline for ZCAMP3 is set to 1 second, and we definitely
% want to stop acquisition before stopping TL.

ip=src.DatagramAddress;
port=src.DatagramPort;
data=fread(src);
str=char(data');
fprintf('Received ''%s'' from %s:%d\n', str, ip, port);

info=dat.mpepMessageParse(str);

% update remote IP to that of the sender (port is standard mpep listening
% port as initialised in SIListener.m)
src.RemoteHost = ip;

switch info.instruction
    case 'hello'
        fwrite(src, data);
    case 'ExpStart'
        % configure save filename and path
        [filePath, fileStem] = dat.expPath(info.expRef, 'main', 'local');
        
        SCAN.animalName = info.subject;
        SCAN.experimentName = info.expRef;
        SCAN.animal = filePath;
        SCAN.images = filePath;
        SCAN.info = filePath;
        SCAN.fus = filePath;
        SCAN.fulldata = filePath;
        SCAN.fileJournal = fullfile(filePath, [info.expRef, '.txt']);
        
        M = src.UserData.motorObj;
        SCAN.H.motorPosition = M.Xmm;
        
        folders{1} = SCAN.images;
        folders{2} = SCAN.info;
        folders{3} = SCAN.fus;
        folders{4} = SCAN.fulldata;
        for iName = 1:length(folders)
            if ~exist(folders{iName}, 'dir')
                [mkSuccess, message] = mkdir(folders{iName});
            end
            if mkSuccess
                fprintf('%s folder successfully created\n', folders{iName});
            else
                error('There was a problem creating %s. %s\n', folders{iName}, message');
            end
        end
        
%         fprintf('let''s send UDP echo\n');
%         fusiWorkaround;
        if ~SCAN.flagRun
%             fprintf('\n\n\nClick START(paused) now, if not clicked yet!\n\n\n');
            fprintf('\n\n\nForgot to click START(paused)!!\nAbort the experiment from mpep and start again\n\n\n');
            load train;
            sound(y, Fs);
            pause(5);
        end
        pause(ExpStartDelay);
%         fprintf('let''s start scanning\n');
        SCAN.flagPause = 0;
        fwrite(src, data);
        
    case {'ExpEnd', 'ExpInterrupt'}
        % abort loop, if not aborted yet
        pause(stopDelay); % wait a bit before stopping imaging
        SCAN.flagRun = 0;
        fprintf('Acquisition stopped\n');
        
        %         [filePath, fileStem] = dat.expPath('2017-01-01_0_junk', 'main', 'local');

        fwrite(src, data);
        
        % Files are saved in the procObj callback function
        
        fprintf('Ready for new acquisition\n');
        
        
    case 'BlockStart'
%         SCAN.flagPause = false;
        fwrite(src, data);
    case 'BlockEnd'
%         SCAN.flagPause = false;
        fwrite(src, data);
    case 'StimStart'
%         SCAN.flagPause = false;
        fwrite(src, data);
    case 'StimEnd'
%         SCAN.flagPause = false;
        fwrite(src, data);
    otherwise
        fprintf('Unknown instruction : %s\n', info.instruction);
        fwrite(src, data);
end

% disp('now the addresses are:');
% fprintf('%s:%d\n', u.DatagramAddress, u.DatagramPort),
% fprintf('now sending %s to the remote host\n', char(data(:))');
% fprintf('%s\n', char(data(:))');
% fprintf

end
%===========================================================
%

