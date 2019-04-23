animalName = 'PC036';

br = Brain(animalName);

nStacks = length(br.yStacks);

%%  select the reference stack

[~, datesRaw, ~] = dat.parseExpRef({br.yStacks.ExpRef});
[dates, sortIdx] = sort(datesRaw);

% let's select a date with the minimum overall distance to all other dates
dist = sum(abs(dates' - dates));
idx = find(dist == min(dist));
if length(idx) > 1
    % if we have more than one candidate, let's also look at a minimum
    % square distance, as a tie-breaker
    dist2 = sum(abs(dates' - dates).^2);
    idx2 = find(dist2(idx) == min(dist2(idx)));
    idx = idx(idx2);
    if length(idx) > 1
        % if still tied, select the earliest one
        idx = idx(1);
    end
end
refStackIndex = sortIdx(idx);


%% get transforms from all stacks to the reference stack

tf = struct('affine', [], 'D', [], 'Rmoving', imref3d, 'Rfixed', imref3d);
tic
for iStack = 1:nStacks
    fprintf('Aligning stack %1.0f/%1.0f\n', iStack, nStacks);
    tf(iStack) = alignStacks(br.yStacks(iStack), br.yStacks(refStackIndex));
    toc
end

%% align all the stacks and calculate an average stack

refStackSize = size(br.yStacks(refStackIndex).getDoppler.doppler);
allStacks = nan([refStackSize, nStacks]);
for iStack = 1:nStacks
    moving = br.yStacks(iStack).getDoppler.doppler;
    [oneStack, ~] = imwarp(moving, tf(iStack).Rmoving, tf(iStack).affine, 'OutputView', tf(iStack).Rfixed, ...
        'SmoothEdges', false, 'FillValues', NaN);
    nanIdx = isnan(oneStack);
    oneStack(nanIdx) = 0;
    oneStack = imwarp(oneStack, tf(iStack).D, 'linear', 'SmoothEdges', false);
    oneStack(nanIdx) = NaN;
    prc = prctile(oneStack(:), [0.1, 99.9]);
    oneStack = min(1, max(0, (oneStack-prc(1))/diff(prc)));
    allStacks(:,:,:,iStack) = oneStack;
end
averageStack = nanmean(allStacks, 4);
ref = br.yStacks(refStackIndex).getDoppler;
ref.doppler = averageStack;
refStack = copy(br.yStacks(refStackIndex));
refStack.Doppler = ref.doppler;
refStack.xAxis = ref.xAxis;
refStack.yAxis = ref.yAxis;
refStack.zAxis = ref.zAxis;

fprintf('Second iteration\n');
tf = struct('affine', [], 'D', [], 'Rmoving', imref3d, 'Rfixed', imref3d);
tic
for iStack = 1:nStacks
    fprintf('Aligning stack %1.0f/%1.0f\n', iStack, nStacks);
    tf(iStack) = alignStacks(br.yStacks(iStack), refStack);
    toc
end

hFig = figure;
br.yStacks(refStackIndex).plotVolume(subplot(2,2,1));
refStack.plotVolume(subplot(2,2,2));
refStack.plotSlices;

%% get transform from all stack sto an average stack
alignStacksPlayground(br.yStacks(2), br.yStacks(3));