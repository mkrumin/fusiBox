classdef  procObj  < handle
    
    properties
      % define user properties here
      saveBF = false;
      saveBFFilt = false;
    end
    
    methods        
        function obj=procObj(h)
           % init the object here  
           obj.saveBF = h.saveBF;
           obj.saveBFFilt = h.saveBFFilt;
        end
        
        function startFus(obj) 
           fprintf('call startFus'); 
        end
        
        function newImage(obj)
            global SCAN
            i=SCAN.fusIndex;
            % there is a misalignment of the timestamps by 2 frames
            t=SCAN.time(i);
            try
                dt = SCAN.time(i) - SCAN.time(i-1);
                fprintf('Image: %d time %.2f, dt = %4.2fs\n',i,t, dt);
            end
            if i==1
                % We start the acquisition in a'paused' mode and then
                % change this flag externally to actually  start the acquisition
                SCAN.flagPause = 1;
            end
            
            if i~=1 && (obj.saveBF || obj.saveBFFilt)
                tic
                saveCurrentBF(SCAN, obj);
                toc
            end
        end
        
        function endFus(obj)
            global SCAN
            fprintf('call endFus\n');
            % save the power doppler movies
            saveDopplerMovie(SCAN)
            % set dummy paths, so that data is not getting overwritten
            setDummyPaths(SCAN);
        end
    end
    
end

