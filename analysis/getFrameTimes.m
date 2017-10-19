function frTimes = getFrameTimes(TL)

% find the channel index of the neuralFrames
iCh = find(ismember({TL.hw.inputs.name}, 'neuralFrames'));

% find sample indices where increments occur 
% (this is a simple edge counter channel)
idx =  find(diff(TL.rawDAQData(:, iCh)))+1;

% and the times will be these
frTimes = TL.rawDAQTimestamps(idx);
frTimes = frTimes(:);