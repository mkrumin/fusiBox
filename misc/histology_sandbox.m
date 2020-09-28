folder = 'Z:\Histology\CR019';
files = dir(fullfile(folder, '*.tiff'));
nFiles = length(files);

for iFile = 1:nFiles
    fTiff = Tiff(fullfile(files(iFile).folder, files(iFile).name));
    figure('Name', files(iFile).name, 'Position', [100 100  1800 650]);
    imagesc(readRGBAImage(fTiff));
    axis equal tight;
end