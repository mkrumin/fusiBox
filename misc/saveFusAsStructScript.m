folder = 'Z:\CR016\';
if ~exist(folder, 'dir')
    mkdir(folder);
end
for iExp = 1:4
    ExpRef{iExp} = sprintf('2019-10-01_%g_CR016', iExp+1);
    fusObj{iExp} = Fus(ExpRef{iExp});
    fusStruct{iExp} = makeStruct(fusObj{iExp});
    tmp = fusStruct{iExp};
    save(fullfile(folder, fusStruct{iExp}.ExpRef), '-struct', 'tmp', '-v7.3', '-nocompression')
end

