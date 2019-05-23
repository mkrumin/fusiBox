function diskSpaceWarning()


z = struct('path', 'Z:', 'free_bytes', [], 'total_bytes', [], 'usable_bytes', []);
[z.free_bytes, z.total_bytes, z.usable_bytes] = disk_free(z.path);


warndlg([printWarning(z)], 'Disk Space Info', 'modal')


function str = printWarning(s)

frameSize = 23228416;
frameRate = 60/0.54;
bytesPerMinute = frameSize * frameRate;
str = cell(4, 1);
str{1} = sprintf('\nThere is %1.0f GB free on drive ''%s''', s.usable_bytes/1024^3, s.path);
str{2} = sprintf('This is enough for %1.0f minutes of BF or BFFilt', s.usable_bytes/bytesPerMinute);
str{3} = sprintf('or %1.0f minutes of both BF and BFFilt acquisition', s.usable_bytes/bytesPerMinute/2);
str{4} = sprintf('(for zSpan = 6mm)');

