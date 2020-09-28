function plotUSVF(U, V, faceU, faceV, faceT)

[nZ, nX, nSVDs] = size(U);
[nT, ~] = size(V);
% tAxis = [1:nT] * dt;

%% plot a collage of all the spatial components
nR = floor(sqrt(nSVDs));
nC = ceil(nSVDs/nR);
nExtraSVDs = nR*nC - nSVDs;
allU = cat(3, mat2cell(U, nZ, nX, ones(nSVDs, 1)), repmat({NaN(nZ, nX)}, 1, 1, nExtraSVDs));
allU = cell2mat(reshape(allU, nC, nR)');
figure;
imagesc(sqrt(abs(allU)))
colormap gray;

%%
nSubplots = 5; % number of subplot per figure
maxSVDs = 15;
nFigures = ceil(nSVDs/nSubplots);
nColumns = 5;
iSVD = 0;
for iFigure = 1:nFigures
    if iSVD >= maxSVDs
        break;
    end
    figure;
    for iSubplot = 1:nSubplots
        iSVD = iSubplot + nSubplots*(iFigure - 1);
        if iSVD > maxSVDs
            break;
        end
        ax = subplot(nSubplots+1, nColumns, 1 + nColumns*(iSubplot - 1));
        imagesc(abs(U(:,:,iSVD)));
        axis square tight off;
        title(iSVD)
        colormap(ax, 'gray')
        
        subplot(nSubplots+1, nColumns, [2:nColumns] + nColumns*(iSubplot - 1));
        plot(real(V(:, iSVD)));
        hold on;
        plot(imag(V(:, iSVD)));
        axis tight off
    end
    
    ax = subplot(nSubplots+1, nColumns, 1 + nColumns*nSubplots);
    imagesc(faceU);
    axis equal tight off;
    caxis([-1 1]*max(abs(faceU(:))));
    colormap(ax, 'redblue');
    subplot(nSubplots+1, nColumns, [2:nColumns] + nColumns*nSubplots);
    plot(faceT, faceV);
    axis tight off;
end