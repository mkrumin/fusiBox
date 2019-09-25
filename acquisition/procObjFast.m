classdef  procObjFast  < handle
    
    properties
      % define user properties here
      saveBF = false;
      saveBFFilt = false;
      pause = 0;
    end
    
    methods        
        function obj=procObjFast(h)
           % init the object here  
%            obj.saveBF = h.saveBF;
%            obj.saveBFFilt = h.saveBFFilt;
        end
        
        function startFus(obj) 
           global SCAN;
           fprintf('call startFus\n'); 
           fprintf('Full data location will be %s\n', SCAN.fileNames);
        end
        
        function newImage(obj)
            global SCAN
            i=SCAN.fusIndex;
            if i<=1 || mod(i, 10)==0
                fprintf('Frame #%1.0f\n', i);
            end
            % there is a misalignment of the timestamps by 2 frames
            
            if i==1
                % We start the acquisition in a 'paused' mode and then
                % change this flag externally to actually  start the acquisition
                SCAN.flagPause = 1;
            end
            
%             try
%             [xx, zz, dt] = SCAN.getAxis;
%             hf = figure(99);
%             hf.Children.Children.XData = xx;
%             hf.Children.Children.YData = zz;
%             drawnow;
%             end
%             if i~=1 && (obj.saveBF || obj.saveBFFilt)
% %                 tic
%                 saveCurrentBF(SCAN, obj);
% %                 toc
%             end
        end
        
        function endFus(obj)
            global SCAN
            fprintf('call endFus\n');
            % save the power doppler movies
%             saveDopplerMovie(SCAN)
            % set dummy paths, so that data is not getting overwritten
%             setDummyPaths(SCAN);
        end
    end
    
end

