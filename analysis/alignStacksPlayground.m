function [alignedStack, tf] = alignStacksPlayground(movYStack, refYStack)

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

% metric = registration.metric.MattesMutualInformation
metric = registration.metric.MeanSquares;
% optimizer = registration.optimizer.OnePlusOneEvolutionary
optimizer = registration.optimizer.RegularStepGradientDescent;
optimizer.MaximumIterations = 1000;
% optimizer.GradientMagnitudeTolerance = 1e-5;
optimizer.MinimumStepLength = 1e-6;

% [optimizer,metric] = imregconfig('multimodal');
PLvls = 3;
DOpt = true;
FillVal = NaN;

% equalize the dynamic range of the two images and clip the outlier voxels
prc = prctile(moving(:), [1, 99]);
moving = min(1, max(0, (moving-prc(1))/diff(prc)));
prc = prctile(fixed(:), [1, 99]);
fixed = min(1, max(0, (fixed-prc(1))/diff(prc)));

moving = double(moving)*256;
fixed = double(fixed)*256;
% moving = imhistmatch(moving, fixed);
%%
% [moving_reg,R_reg] = imregister(moving,Rmoving,fixed,Rfixed,transformType,optimizer,metric, ...
%     'DisplayOptimization', true, 'InitialTransformation', affine3d, 'PyramidLevels', 3);

fprintf('Translation: \n')
tFormTranslate = imregtform(moving,Rmoving,fixed,Rfixed,'translation',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', affine3d, 'PyramidLevels', PLvls);
[regTranslation, ~] = imwarp(moving, Rmoving, tFormTranslate, 'OutputView', Rfixed, ...
    'SmoothEdges', false, 'FillValue', FillVal);
tFormTranslate.T

fprintf('Rigid: \n')
tFormRigid = imregtform(moving,Rmoving,fixed,Rfixed, 'rigid',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormTranslate, 'PyramidLevels', PLvls);
[regRigid, Rrigid] = imwarp(moving,Rmoving,tFormRigid,'OutputView',Rfixed, ...
    'SmoothEdges', false, 'FillValue', FillVal);
tFormRigid.T

% fprintf('Similarity (rigid + scaling): \n');
% tFormSimilarity = imregtform(moving,Rmoving,fixed,Rfixed, 'similarity',optimizer,metric, ...
%     'DisplayOptimization', DOpt, 'InitialTransformation', tFormRigid, 'PyramidLevels', PLvls);
% [regSimilarity,R_reg] = imwarp(moving,Rmoving,tFormSimilarity,'OutputView',Rfixed, 'SmoothEdges', false);
% tFormSimilarity.T
%
fprintf('Affine:\n');
tFormAffine = imregtform(moving,Rmoving,fixed,Rfixed, 'affine',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormRigid, 'PyramidLevels', PLvls);
[regAffine, ~] = imwarp(moving,Rmoving,tFormAffine,'OutputView',Rfixed, ...
    'SmoothEdges', false, 'FillValue', FillVal);
[regAffine2, ~] = imwarp(moving,Rmoving,tFormAffine,'OutputView',Rrigid, ...
    'SmoothEdges', false, 'FillValue', FillVal);
tFormAffine.T


% [moving_reg,R_reg] = imregister(moving,Rmoving,fixed,Rfixed,'affine',optimizer,metric, ...
%     'DisplayOptimization', true, 'InitialTransformation', tFormAffine, 'PyramidLevels', 3);


%%
% D = imregdemons(regAffine, fixed, 200, 'AccumulatedFieldSmoothing', 0.5);
regAffineNoNan = regAffine; 
regAffineNoNan(isnan(regAffine)) = 0;
D = imregdemons(regAffineNoNan, fixed, 100, 'AccumulatedFieldSmoothing', 2, ...
    'DisplayWaitbar', true);
regDisp = imwarp(regAffineNoNan, D, 'linear', 'SmoothEdges', false, 'FillValue', FillVal);


%%

for iSlice = 1:5:min(size(fixed, 3), size(moving, 3))
    figure('Name', num2str(iSlice), 'Position', [20, 100, 1600, 1000]);
    nRows = 2;
    nColumns = 3;
    method = 'falsecolor';
    fix = (fixed(:,:,iSlice));
    mov = (moving(:,:,iSlice));
    movTr = (regTranslation(:,:,iSlice));
    movRig = (regRigid(:,:,iSlice));
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
    im = imshowpair(fix, movAff, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 4));
    set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
    title('Affine');
    im = imshowpair(movRig, movAff2, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 5));
    set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
    title('Affine vs. Rigid');
    im = imshowpair(fix, movDis, method, 'Scaling', 'independent', 'Parent', subplot(nRows, nColumns, 6));
%     im = imagesc(subplot(nRows, nColumns, 6), squeeze(D(:,:,iSlice,:)));
    set(im, 'XData', refData.xAxis, 'YData', refData.zAxis); axis equal tight;
    title('Displacement Field');
end
