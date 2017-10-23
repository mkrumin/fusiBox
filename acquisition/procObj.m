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
            t=SCAN.time(i+2);
            fprintf('newImage, Image: %d time %.2f\n',i,t); 
            if i==1
                % We start the acquisition in a'paused' mode and then
                % change thid flag externally to actually  start the acquisition
               SCAN.flagPause = 1;
            else
                saveCurrentBF(SCAN);
            end
        end
        
        function endFus(PO)
            global SCAN
            fprintf('call endFus\');
            % save the power doppler movies
            saveDopplerMovie(SCAN)
            % set dummy paths, so that data is not getting overwritten
            setDummyPaths(SCAN);

        end
    end
    
end

