function preprocessYS(dataFile, saveFile, maskFile)

load(maskFile);

mask = YSLite.mask;

clear YSLite;

load(dataFile);

YS.mask = mask;
% Mask the brain
YS.applyMask;
% do the preprocessing
nSVDs = 500;
fprintf('Peforming SVD decomposition (%g SVDs) ..', nSVDs);
svdTic = tic;
YS.svdDecomposition(nSVDs);
fprintf('. done (%1.0f seconds)\n', toc(svdTic));
fprintf('Rotating the dI/I SVD decomposition basis ..');
diiTic = tic;
YS.svddII(0);
fprintf('. done (%1.0f seconds)\n', toc(diiTic));
fprintf('Performing doppler registration:\n');
regTic = tic;
YS.regDoppler;
t = toc(regTic); 
h = floor(t/3600); m = floor(mod(t,3600)/60); s = floor(mod(t, 60));
fprintf('Total time spent on registration - %02.0fh%02.0fm%02.0fs\n', h, m, s)
fprintf('Detecting outlier frames ..');
outTic = tic;
YS.getOutliers(Inf);
fprintf('. done (%3.1f seconds)\n', toc(outTic));
fprintf('Processing fast doppler:\n');
fastTic = tic;
YS.processFastDoppler;
fprintf('Done processing fast doppler in %1.0f seconds\n', toc(fastTic));
fprintf('Calculating dII directly from doppler movies ..');
diiTic = tic;
YS.getdII;
fprintf('. done (%3.1f seconds)\n', toc(diiTic));
t = toc(svdTic); 
h = floor(t/3600); m = floor(mod(t,3600)/60); s = floor(mod(t, 60));
fprintf('Total time spent preprocessing the whole dataset - %02.0fh%02.0fm%02.0fs\n', h, m, s)

fprintf('Saving to %s ..', saveFile);
saveTic = tic;
YS.saveLite(saveFile);
fprintf('. done (%3.1f seconds)\n', toc (saveTic))