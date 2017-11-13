function hwInfo = getHardwareInfo(ExpRef)

[folder, file] = dat.expPath(ExpRef, 'main', 'master');

filename = [file, '_hardwareInfo.mat'];


% load the screen ino, trying to catch and fix the path issue 
% (data\ vs. data2\)
try 
    hw = load(fullfile(folder, filename));
catch
    if contains(folder, 'data\')
        folder = strrep(folder, 'data\', 'data2\');
    elseif contains(folder, 'data2\')
        folder = strrep(folder, 'data2\', 'data\');
    end
    hw = load(fullfile(folder, filename));
end

hwInfo = hw.myScreenInfo;
