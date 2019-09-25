function data = getParameters(S)

%%
props = properties(S);

data = struct;
for i= 1:length(props)
    if ismember(props{i}, {'RF', 'BF', 'BFfilt', 'I1', 'BFobj'})
        % do not save these fields, they might take substantial amount of
        % space
        continue;
    elseif ismember(props{i}, {'S', 'H', 'BFobj', 'SYobj', 'Timers'})
        % same for the R07PX version, plus remove the unnecessary objects
        % they will cause errors/warning when loading the data later on
        continue;
    else
        data.(props{i}) = S.(props{i});
    end
end

try
    data.sizeRF = size(S.RF{1});
    data.sizeBF = size(S.BF{1});
    data.sizeBFFilt = size(S.BFfilt);
end

