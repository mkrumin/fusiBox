animalName = 'CR013_DRI2';

stacksList = getAllStacks(animalName);
nStacks = length(stacksList);
clear st;
for iStack = 1:nStacks
    st(iStack) = YStack(stacksList{iStack});
end

%%
for iStack = 1:nStacks
    h = st(iStack).plotVolume;
    st(iStack).plotSlices;
end

%%
F = struct;
figure(h);
ax = gca;
axis off tight;
ax.Title.Visible = 'off';
ax.CameraTargetMode = 'manual';
azimuth = -30 + [0:1:359];
nFrames = length(azimuth);
view(ax, azimuth(1), 20)
drawnow;
pause(0.01);
F = getframe(h);
for iFrame = 2:nFrames
    fprintf('Rendering frame #%g/%g\n', iFrame, nFrames);
    view(ax, azimuth(iFrame), 20)
    drawnow;
    pause(0.1);
    F(iFrame) = getframe(h);
end
    