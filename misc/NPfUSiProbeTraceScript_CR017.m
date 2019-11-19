
expNums = [2210, 2214, 2215, 2217, 2223, 2225, 2226, 2229];
for iExp = 1:numel(expNums)
    filename = sprintf('%s%4.0f\\2019-11-13_%4.0f_CR017_fUSiYStack.mat', ...
        '\\znas.cortexlab.net\\Subjects\CR017\2019-11-13\', expNums(iExp), expNums(iExp));
    data(iExp) = load(filename);
end

%%
expNums = [2109 2111 2113 2114 2115 2116 2117 2119 2120 2121 2123];
for iExp = 1:numel(expNums)
    filename = sprintf('%s%4.0f\\2019-11-14_%4.0f_CR017_fUSiYStack.mat', ...
        '\\znas.cortexlab.net\\Subjects\CR017\2019-11-14\', expNums(iExp), expNums(iExp));
    data(iExp) = load(filename);
end

%%
yy = [data.yCoords];
yyUnique = unique(yy);
nRows = numel(yyUnique);
figure
for iY = 1:numel(yyUnique)
    tmp = [data(yy == yyUnique(iY)).Doppler];
    xAxis = tmp(1).xAxis;
    zAxis = tmp(1).zAxis;
    fus = cell2mat(reshape({tmp.yStack}, 1, 1, []));
    fus = sqrt(fus);
%     figure('Name', sprintf('CR017, y = %g [mm]', yyUnique(iY)), ...
%         'Position', [272         682        1200         275]);
    subplot(nRows, 3, 1 + (iY - 1) * 3); 
    imagesc(xAxis, zAxis, min(fus, [], 3)); 
    axis equal tight
    xlabel('x [mm]');
    ylabel('z [mm]');
    title('min');
    subplot(nRows, 3, 2 + (iY - 1) * 3); 
    imagesc(xAxis, zAxis, max(fus, [], 3)); 
    axis equal tight
    title({sprintf('y = %g [mm]', yyUnique(iY)); 'max'});
    subplot(nRows, 3, 3 + (iY - 1) * 3); 
    imagesc(xAxis, zAxis, max(fus, [], 3) - min(fus, [], 3)); 
    axis equal tight
    title('diff');
    colormap hot
end