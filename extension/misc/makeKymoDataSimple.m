mts = mts2;
sf = Data(:,1);
for i = 1:length(mts)
    k = 1;
    for j = 1:length(mts{i})
        if ~isempty(mts{i}{j})
            mts{i}{j}{6} = sf{i}(k,2);
            k = k+1;
        end
    end
    mts{i} = mts{i}(~cellfun(@isempty,mts{i}));
    if k ~= length(mts{i})+1
        error('');
    end
end
