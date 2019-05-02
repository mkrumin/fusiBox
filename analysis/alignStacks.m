function tf = alignStacks(movYStack, refYStack)

if isa(movYStack, 'YStack')
    %this is an instance of YStack
    % get the cropped data from these YStack objects
    movData = getDoppler(movYStack);
else
    % this is already a structure with necessary fields
    movData = movYStack;
end
if isa(refYStack, 'YStack')
    %this is an instance of YStack
    % get the cropped data from these YStack objects
    refData = getDoppler(refYStack);
else
    % this is already a structure with necessary fields
    refData = refYStack;
end



%% Define 
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

PLvls = 3;
DOpt = false;

%% equalize the dynamic range of the two images and clip the outlier voxels
prc = prctile(moving(:), [1, 99]);
moving = min(1, max(0, (moving-prc(1))/diff(prc)));
prc = prctile(fixed(:), [1, 99]);
fixed = min(1, max(0, (fixed-prc(1))/diff(prc)));

moving = double(moving)*256;
fixed = double(fixed)*256;
%% Estimate geometric transformations
tFormTranslate = imregtform(moving,Rmoving,fixed,Rfixed,'translation',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', affine3d, 'PyramidLevels', PLvls);
tFormRigid = imregtform(moving,Rmoving,fixed,Rfixed, 'rigid',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormTranslate, 'PyramidLevels', PLvls);
tFormAffine = imregtform(moving,Rmoving,fixed,Rfixed, 'affine',optimizer,metric, ...
    'DisplayOptimization', DOpt, 'InitialTransformation', tFormRigid, 'PyramidLevels', PLvls);
%% Estimate displacement field for local corrections on top of affine transformation
[regAffine, ~] = imwarp(moving, Rmoving, tFormAffine, 'OutputView', Rfixed, ...
    'SmoothEdges', false);
D = imregdemons(regAffine, fixed, [600 400 200], 'AccumulatedFieldSmoothing', 2, ...
    'DisplayWaitbar', false);

tf.affine = tFormAffine;
tf.D = D;
tf.Rmoving = Rmoving;
tf.Rfixed = Rfixed;
