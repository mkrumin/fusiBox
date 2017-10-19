function udpTimes = getUDPTimes(TL, str)

% if no pattern was defined return all the UDP times
if nargin < 2 || isempty(str)
    udpTimes = TL.mpepUDPTimes(1:TL.mpepUDPCount);
    return
end

% find which UDPs have the required string
idx = cellfun(@(x) length(strfind(x, str)), TL.mpepUDPEvents(1:TL.mpepUDPCount));
idx = find(idx);
% find corresponding timestamps
udpTimes = TL.mpepUDPTimes(idx);
