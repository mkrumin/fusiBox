function delayedExpEnd(src, event)

global SCAN

fusData = acqLoop;
timestamp = datestr(now, '[HH:MM:SS.FFF]');
fprintf('\n%s [expendTimer] saving data to disk\n', timestamp);
saveDopplerMovie(SCAN, fusData);

timestamp = datestr(now, '[HH:MM:SS.FFF]');
fprintf('\n%s [expendTimer] echoing\n', timestamp);
usrd = src.UserData;
fwrite(usrd.u, usrd.str);

timestamp = datestr(now, '[HH:MM:SS.FFF]');
fprintf('\n%s [expendTimer] Ready for new acquisition\n', timestamp);
