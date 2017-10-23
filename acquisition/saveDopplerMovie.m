function saveDopplerMovie(obj)

iFrame = obj.fusIndex;
% timeStamp = obj.time(iFrame+2);

folderName = obj.fus;
fileName = sprintf('%s_fus.mat', obj.experimentName);

fullFileName = fullfile(folderName, fileName);
% I = obj.I1;

doppler.frames = obj.I1(:,:,1:iFrame);
% again, there is timestamp misalignment because of the initial two frames
doppler.softTimes = obj.time(3:iFrame+2);
[xAxis, zAxis, dt] = obj.getAxis;
doppler.xAxis = xAxis;
doppler.zAxis = zAxis;
doppler.dtBF = dt(1);
doppler.dtSinglePlanewave = dt(2);
doppler.dtRF = dt(3);

save(fullFileName, 'doppler', '-v6')
