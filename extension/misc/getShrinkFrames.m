data = cell(length(Objects),2);
files = cell(length(Objects),1);
for i=1:length(Objects)
    ids = Objects(i).TrackIds;
    ids = ids(ids>0);
    st = Tracks(ids);
    st = st([st.Shrinks]);
%     c = ismember(Objects(i).DynResults(:,1), f);
%     c = imdilate(c, [1; 1; 1]);
%     indexes = find(c);
    data{i,1} = st;
    data{i,2} = Objects(i).Name;
    files{i} = [Objects(i).LoadedFromPath];
end
[savefiles,cids] = unique(files);
cids(end+1) = length(files)+1;
for i = 1:length(savefiles)
    Data = data(cids(i):cids(i+1)-1,:);
    save([savefiles{i} 'shrinkingframes3'], 'Data')
end