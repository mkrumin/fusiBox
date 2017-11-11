function data = getParameters(S)

%%
props = properties(S);

data = struct;
for i= 1:length(props)
    if ismember(props{i}, {'RF', 'BF', 'BFfilt', 'I1'})
        % do not save these fields
        continue;
    else
        data.(props{i}) = S.(props{i});
    end
end