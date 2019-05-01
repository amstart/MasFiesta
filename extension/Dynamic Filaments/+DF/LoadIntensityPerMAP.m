function LoadIntensityPerMAP(FileName, PathName)
%reads a table and matches values and associated objects
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
table = readtable([PathName FileName], 'Format', '%s%s%d', 'Delimiter','\t');
for i = 1:length(table.Value)
    if strcmp(table.Moviefolder(i),'all')
        changeobjects = cellfun(@(x) ~isempty(strfind(x, table.Folder{i})), LoadedFromPath);
        for id = find(changeobjects==1)
            Objects(id).Custom.IntensityPerMAP = double(table.Value(i));
        end
    end
end
for i = 1:length(table.Value)
    if ~strcmp(table.Moviefolder(i),'all')
        changeobjects = cellfun(@(x) contains(x, table.Folder{i}), LoadedFromPath) & cellfun(@(x) contains(x, [filesep table.Moviefolder{i}]), LoadedFromPath);
        for id = find(changeobjects==1)
            Objects(id).Custom.IntensityPerMAP = double(table.Value(i));
        end
    end
end
setappdata(hDFGui.fig,'Objects',Objects);
setappdata(0,'hDFGui',hDFGui);