function plotUSV(U, S, V, dt)

[nZ, nX, nSVDs] = size(U);
[nT, ~] = size(V);
tAxis = [1:nT] * dt;

%% plot a collage of all the spatial components
nR = floor(sqrt(nSVDs));
nC = ceil(nSVDs/nR);
nExtraSVDs = nR*nC - nSVDs;
allU = cat(3, mat2cell(U, nZ, nX, ones(nSVDs, 1)), repmat({NaN(nZ, nX)}, 1, 1, nExtraSVDs));
allU = cell2mat(reshape(allU, nC, nR)');
figure;
imagesc(sqrt(abs(allU)))

%%
nSubplots = 6; % number of subplot per figure

nFigures = ceil(nSVDs/nSubplots);
nColumns = 5;
for iFigure = 1:nFigures
    figure;
    for iSubplot = 1:nSubplots
        iSVD = iSubplot + nSubplots*(iFigure - 1);
        if iSVD > nSVDs
            break;
        end
        subplot(nSubplots, nColumns, 1 + nColumns*(iSubplot - 1));
        imagesc(abs(U(:,:,iSVD)));
        axis square tight off;
        title(iSVD)
        
        subplot(nSubplots, nColumns, [2:nColumns] + nColumns*(iSubplot - 1));
        plot(tAxis, imag(V(:, iSVD)));
        hold on;
        plot(tAxis, real(V(:, iSVD)));
        axis off
        % plot V here
    end
end