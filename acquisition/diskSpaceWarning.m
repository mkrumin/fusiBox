function diskSpaceWarning(obj)


z = struct('path', 'Z:', 'free_bytes', [], 'total_bytes', [], 'usable_bytes', []);
[z.free_bytes, z.total_bytes, z.usable_bytes] = disk_free(z.path);

if nargin > 0
    warndlg([printWarning(z, obj)], 'Disk Space Info', 'modal')
else
    warndlg([printWarning(z)], 'Disk Space Info', 'modal')
end


function str = printWarning(s, obj)

if nargin == 1
    % old version (v19.4b)
    frameSize = 23228416;
    frameRate = 60/0.54;
    bytesPerMinute = frameSize * frameRate;
    str = cell(4, 1);
    str{1} = sprintf('\nThere is %1.0f GB free on drive ''%s''', s.usable_bytes/1024^3, s.path);
    str{2} = sprintf('This is enough for %1.0f minutes of BF or BFFilt', s.usable_bytes/bytesPerMinute);
    str{3} = sprintf('or %1.0f minutes of both BF and BFFilt acquisition', s.usable_bytes/bytesPerMinute/2);
    str{4} = sprintf('(for zSpan = 6mm)');
else
    % new version (e.g. R07PX)
    [xx, zz, tt] = obj.getAxis;
    frameSize = numel(xx) * numel(zz) * 4 * 2; % complex single data type
    frameRate = 60/tt(1); % tt(1) is the dt of the compound frames
    bytesPerMinute = frameSize * frameRate;
    str = cell(4, 1);
    str{1} = sprintf('\nThere is %1.0f GB free on drive ''%s''', s.usable_bytes/1024^3, s.path);
    str{2} = sprintf('This is enough for %1.0f minutes of BF', s.usable_bytes/bytesPerMinute);
    str{3} = sprintf('(for current settings of depth and width)');
end

