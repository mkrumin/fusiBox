function hwInfo = getHardwareInfo(ExpRef)

[folder, file] = dat.expPath(ExpRef, 'main', 'master');

filename = [file, '_hardwareInfo.mat'];

% load the screen info, trying to catch and fix the path issue 
% (data\ vs. data2\)
try 
    hw = load(fullfile(folder, filename));
    hwInfo = hw.myScreenInfo;
catch
    if contains(folder, 'data\')
        folder = strrep(folder, 'data\', 'data2\');
    elseif contains(folder, 'data2\')
        folder = strrep(folder, 'data2\', 'data\');
    end
    try
    hw = load(fullfile(folder, filename));
    hwInfo = hw.myScreenInfo;
    catch
        filename = strrep(filename, '.mat', '.json');
        fid = fopen(fullfile(folder, filename));
        txt = fread(fid);
        fclose(fid);
        hwInfo = jsondecode(char(txt(:)'));
    end
    
end

