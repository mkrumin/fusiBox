% this is a script for creating YStack objects, adding associated functional
% fusi data and related metadata from the server with some minimal
% preprocessing

% For each experimental day (a single YSTack + multiple Fus objects) 
% all the data is saved in a single file with the name (ExpRef)_YS.mat

animalNames = {'CR015'};
rootDataFolder = 'F:\fUSiData\';
nMice = length(animalNames);
%%
for iMouse = 1:nMice
%     fprintf('Loading data for %s \n', animalNames{iMouse})
%     summary{iMouse} = getAllFusiExps(animalNames{iMouse});
    nYSs(iMouse) = length(summary{iMouse});    
end

%%

fprintf('Loading the ''structural'' YStacks..');
tic
for iMouse = 1:nMice
    for iYS = 1:nYSs(iMouse)
        ystacks{iMouse}(iYS) = YStack(summary{iMouse}(iYS).stackRef);
    end
end
fprintf('.done\n');
toc

%%
fprintf('We''ve got %g YStacks across %d mice, let''s do some data cropping\n', sum(nYSs), nMice)
for iMouse = 1:nMice
    for iYS = 1:nYSs(iMouse)
        h = ystacks{iMouse}(iYS).manualCrop;
        close(h);
    end
end

%%
% switch off annoying warning when loading video acquisition objects
warning('off', 'MATLAB:subscripting:noSubscriptsSpecified');

fprintf('Now let me load, re-arrange, crop, and save all the functional data, this might take a while\n')
totalTic = tic;
for iMouse = 1:nMice
    mouseTic = tic;
    fprintf('Processing mouse %s (%g/%g), we have %g YStacks for it\n', ...
        animalNames{iMouse}, iMouse, nMice, nYSs(iMouse));
    for iYS = 1:nYSs(iMouse)
        stackTic = tic;
        nFus = length(summary{iMouse}(iYS).fusRef);
        fprintf('Processing YStack %s (%g/%g), there are %g functional datasets associated with it\n', ...
            ystacks{iMouse}(iYS).ExpRef, iYS, nYSs(iMouse), nFus);
        YS = copy(ystacks{iMouse}(iYS));
        for iFus = 1:nFus
            fusTic = tic;
            fprintf('Loading data for %s (dataset %g/%g)...\n', ...
                summary{iMouse}(iYS).fusRef{iFus}, iFus, nFus);
            YS.addFus(summary{iMouse}(iYS).fusRef{iFus});
            YS.fusi(iFus).hardCrop;
            fprintf('Loading %s done in %1.0f seconds\n', summary{iMouse}(iYS).fusRef{iFus}, toc(fusTic));
        end
        folderName = fullfile(rootDataFolder, animalNames{iMouse});
        filename = fullfile(folderName, [YS.ExpRef, '_YS.mat']);
        fprintf('Processing %s stack took %1.0f seconds\n', YS.ExpRef, toc(stackTic));
        saveTic = tic;
        fprintf('Saving YStack %s (%g/%g) to %s ..', YS.ExpRef, iYS, nYSs(iMouse), filename);
        if ~exist(folderName, 'dir')
            [status, msg] = mkdir(folderName);
            if ~status
                warning('Couldn''t create folder %s, stopping on ''keyboard'' for manual saving of data', folderName);
                keyboard;
            end
        end
        if exist(filename, 'file')
            quest = sprintf('File %s already exists. Overwrite?', filename);
            answer = questdlg(quest, 'Overwrite file?', 'Yes', 'Cancel', 'Cancel');
            switch answer
                case 'Yes'
                    save(filename, 'YS', '-v7.3', '-nocompression');
                case 'Cancel'
                    fprintf('\nSkipping saving file %s \n', filename);
                    fprintf('Will now stop on ''keyboard'' to let you save things manually and then continue on\n');
                    keyboard;
                otherwise
                    fprintf('\nIt looks like you just closed the dialog box\n');
                    fprintf('Will now stop on ''keyboard'' to let you decide what to do and then continue on\n');
                    keyboard;
            end
        else
            save(filename, 'YS', '-v7.3', '-nocompression');
        end
        fprintf('. done (%1.0f seconds)\n', toc(saveTic))
        fprintf('Total for stack %s - %1.0f seconds\n\n', YS.ExpRef, toc(stackTic));
        delete(YS);
        clear YS;
    end
    fprintf('Processing mouse %s took %1.0f seconds\n\n\n', animalNames{iMouse}, toc(mouseTic));
end

fprintf('Everything completed in %1.0f seconds\n', toc(totalTic));

% switch that annoying warning back on
warning('on', 'MATLAB:subscripting:noSubscriptsSpecified');
