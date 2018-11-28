classdef  procObj  < handle
    
    properties
      % define user properties here
    end
    
    methods        
        function PO=prcObj()
           % init the object here  
        end
        
        function startFus(PO) 
           fprintf('call startFus'); 
        end
        
        function newImage(PO)
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
            %             saveCurrentBF(SCAN);
        end
        
        function endFus(PO)
            global SCAN
            fprintf('call endFus\n');
            % save the power doppler movies
            saveDopplerMovie(SCAN)
            % set dummy paths, so that data is not getting overwritten
            setDummyPaths(SCAN);
        end
    end
    
end

