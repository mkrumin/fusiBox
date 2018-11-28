function saveDopplerMovie(obj, frames)

iFrame = obj.fusIndex;

folderName = obj.fus;
fileName = sprintf('%s_fus.mat', obj.experimentName);

fullFileName = fullfile(folderName, fileName);
% I = obj.I1;

if nargin>1
    doppler.frames = frames;
    % for fast doppler we have no software timing data
    doppler.softTimes = [];
else
    doppler.frames = obj.I1(:,:,1:iFrame);
    doppler.softTimes = obj.time(1:iFrame);
end
[xAxis, zAxis, dt] = obj.getAxis;
doppler.xAxis = xAxis;
doppler.zAxis = zAxis;
doppler.motorPosition = obj.HARD.motorPosition;
doppler.nBFPerFrame = obj.parSeq.HQ.NfrBk;
doppler.dtBF = dt(1);
doppler.dtSinglePlanewave = dt(2);
doppler.dtRF = dt(3);
doppler.params = getParameters(obj);

save(fullFileName, 'doppler', '-v6')
