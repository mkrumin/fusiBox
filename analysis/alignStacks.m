function [alignedStack, tf] = alignStacks(refYStack, movYStack)

% get the cropped data from these YStack objects
refData = getDoppler(refYStack);
movData = getDoppler(movYStack);

figure
subplot(1, 2, 1);
refYStack.plotVolume(gca);
subplot(1, 2, 2)
movYStack.plotVolume(gca);

% keyboard;

%%
moving = sqrt(movData.doppler);
dx = diff(movData.xAxis(1:2));
dy = diff(movData.yAxis(1:2));
dz = diff(movData.zAxis(1:2));
Rmoving = imref3d(size(moving), dx, dz, dy);
fixed = sqrt(refData.doppler);
dx = diff(refData.xAxis(1:2));
dy = diff(refData.yAxis(1:2));
dz = diff(refData.zAxis(1:2));
Rfixed = imref3d(size(fixed), dx, dz, dy);
% transformType = 'translation'; % 'rigid', 'similarity', 'affine'
[optimizer,metric] = imregconfig('multimodal');
optimizer.MaximumIterations = 300;
% optimizer.GrowthFactor = 1.1;
% optimizer.InitialRadius = 2*6.25e-3;
PLvls = 3;
DOpt = false;

% moving = imhistmatch(moving,fixed);

%%
% [moving_reg,R_reg] = imregister(moving,Rmoving,fixed,Rfixed,transformType,optimizer,metric, ...
%     'DisplayOptimization', true, 'InitialTransformation', affine3d, 'PyramidLevels', 3);

fprintf('Translation: \n')
tFormTranslate = imregtform(moving,Rmoving,fixed,Rfixed,'translation',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', affine3d, 'PyramidLevels', PLvls);
[regTranslation, ~] = imwarp(moving, Rmoving, tFormTranslate, 'OutputView', Rfixed, 'SmoothEdges', false);
tFormTranslate.T

fprintf('Rigid: \n')
tFormRigid = imregtform(moving,Rmoving,fixed,Rfixed, 'rigid',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormTranslate, 'PyramidLevels', PLvls);
[regRigid,Rrigid] = imwarp(moving,Rmoving,tFormRigid,'OutputView',Rfixed, 'SmoothEdges', false);
tFormRigid.T

fprintf('Similarity (rigid + scaling): \n');
tFormSimilarity = imregtform(moving,Rmoving,fixed,Rfixed, 'similarity',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormRigid, 'PyramidLevels', PLvls);
[regSimilarity,R_reg] = imwarp(moving,Rmoving,tFormSimilarity,'OutputView',Rfixed, 'SmoothEdges', false);
tFormSimilarity.T

fprintf('Affine:\n');
tFormAffine = imregtform(moving,Rmoving,fixed,Rfixed, 'affine',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormSimilarity, 'PyramidLevels', PLvls);
[regAffine,R_reg] = imwarp(moving,Rmoving,tFormAffine,'OutputView',Rfixed, 'SmoothEdges', false);
[regAffine2,R_reg] = imwarp(moving,Rmoving,tFormAffine,'OutputView',Rrigid, 'SmoothEdges', false);
tFormAffine.T


% [moving_reg,R_reg] = imregister(moving,Rmoving,fixed,Rfixed,'affine',optimizer,metric, ...
%     'DisplayOptimization', true, 'InitialTransformation', tFormAffine, 'PyramidLevels', 3);


%%
% D = imregdemons(regAffine, fixed, 200, 'AccumulatedFieldSmoothing', 0.5);
D = imregdemons(regAffine, fixed, [500 400 200], 'AccumulatedFieldSmoothing', 3);
regDisp = imwarp(regAffine, D, 'linear');%, 'OutputView', Rfixed, 'SmoothEdges', false);


%%

for iSlice = 1:5:41
    figure
nRows = 2;
nColumns = 3;
method = 'falsecolor';
fix = (fixed(:,:,iSlice));
mov = (moving(:,:,iSlice));
movTr = (regTranslation(:,:,iSlice));
movRig = (regRigid(:,:,iSlice));
movSim = (regSimilarity(:,:,iSlice));
movAff = (regAffine(:,:,iSlice));
movAff2 = (regAffine2(:,:,iSlice));
movDis = regDisp(:,:,iSlice);
im = imshowpair(fix, mov, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 1));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Original');
im = imshowpair(fix, movTr, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 2));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Translation');
im = imshowpair(fix, movRig, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 3));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Rigid');
im = imshowpair(fix, movSim, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 4));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Similarity');
im = imshowpair(fix, movAff, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 5));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Affine');
im = imshowpair(movRig, movAff2, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 6));
set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
title('Affine vs. Rigid');

% im = imshowpair(fix, movDis, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 6));
% % im = imagesc(subplot(nRows, nColumns, 6), squeeze(D(:,:,iSlice,:)));
% set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
% title('Displacement Field');
end