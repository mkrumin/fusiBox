classdef  procObj  < handle
    
    properties
      % define user properties here
    end
    
    methods        
        function PO=prcObj()
           % init the object here  
        end
        
        function startFus(PO) 
           global SCAN
           display('call startFus'); 
        end
           
        
        function newImage(PO)
            global SCAN 
            i=SCAN.fusIndex;
            t=SCAN.time(i+2);
            fprintf('newImage, Image: %d time %.2f\n',i,t); 
            if i==1
               SCAN.flagPause = 1;
            else
                saveCurrentBF(SCAN);
            end
        end
        
        function endFus(PO)
            global SCAN
            display('call endFus');
            saveDopplerMovie(SCAN)
            setDummyPaths(SCAN);

        end
    end
    
end

