function fUSiUDPCallback_fast(src, event)

% fprintf('%s:%d\n', u.DatagramAddress, u.DatagramPort),
% u.RemoteHost=u.DatagramAddress;
% u.RemotePort=u.DatagramPort;
% disp('now reading data');

% persistent folders
global SCAN
persistent t

ExpStartDelay = 3;
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
        SCAN.images = fullfile(filePath, 'images');
        SCAN.info = fullfile(filePath, 'info');
        SCAN.fus = fullfile(filePath, 'fus');
        SCAN.fulldata = fullfile(filePath, 'fulldata');
        SCAN.fileJournal = fullfile(filePath, 'info', [info.expRef, '.txt']);
        
        folders{1} = SCAN.images;
        folders{2} = SCAN.info;
        folders{3} = SCAN.fus;
        folders{4} = SCAN.fulldata;
        for iName = 1:length(folders)
            [mkSuccess, message] = mkdir(folders{iName});
            if mkSuccess
                fprintf('%s folder successfully created\n', folders{iName});
            else
                error('There was a problem creating %s. %s\n', folders{iName}, message');
            end
        end
        
        t = timer;
        t.ExecutionMode = 'fixedSpacing';
        t.Period = 0.03;
        t.TimerFcn = @acqLoop;
        t.StartDelay = 1;
        SCAN.flagRun = false;
        % make sure the clear the buffered data
        clear acqLoop;
        start(t);
        SCAN.flagRun = 1;
        pause(ExpStartDelay);
        fwrite(src, data);
        
    case {'ExpEnd', 'ExpInterrupt'}
        % abort loop, if not aborted yet
        pause(stopDelay); % wait a bit before stopping imaging
        % not sure this works properly with fUSi, it might just block the
        % execution thread
        stop(t);
        while ~isequal(t.Running, 'off')
            pause(0.1);
        end
        SCAN.flagRun = 0;
        pause(1); % let fUSi stop, if still running
        fprintf('Acquisition stopped\n');
        
        fprintf('retrieving data from memory\n')
        fusData = acqLoop;
        fprintf('saving data to disk\n');
        saveDopplerMovie(SCAN, fusData);
        % clear persistent variables inside the acqLoop function
%         fprintf('clear acLoop\n')
%         clear acqLoop;
        
        fprintf('echoing\n');
        fwrite(src, data);
        
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
        fprintf('Unknown instruction : %s', info.instruction);
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

