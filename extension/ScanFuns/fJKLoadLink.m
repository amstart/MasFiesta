function [ tracks ] = fJKLoadLink(LinkFileName, LinkPathName, fun)
%FJKLOADLINK This function takes the path of a file with a list of 
%file locations. It also takes a function which is applied to each of those
%files. Parameters are not directly passed nor is anything returned (-> use global variables or appdata)
global suppress_progressdlg
suppress_progressdlg = 0;
tmpstruc = load([LinkPathName LinkFileName]);
LoadedFromFile = tmpstruc.LoadedFromFile;
LoadedFromPath = tmpstruc.LoadedFromPath;
numfiles = length(LoadedFromFile);
DiskStr = cell(1, numfiles);
RestPathStr = cell(1, numfiles);
for i = 1:numfiles
    LoadedFromPath{i} = strrep(LoadedFromPath{i}, '/', filesep);
    LoadedFromPath{i} = strrep(LoadedFromPath{i}, '\', filesep);
    FileSepIDs = strfind(LoadedFromPath{i}, filesep);
    DiskStr{i} = LoadedFromPath{i}(1:FileSepIDs(min(3, length(FileSepIDs))));
    RestPathStr{i} = LoadedFromPath{i}(FileSepIDs(min(3, length(FileSepIDs)))+1:end);
end
[UniqueStrings, ~, idwhichUnique] = unique(DiskStr);
progressdlg('String','Loading Files','Min',0,'Max',numfiles);
tracks = {};
for i = 1:numfiles
    suppress_progressdlg = 1;
    FileName = LoadedFromFile{i};
    PathName = [LinkPathName RestPathStr{i}];
    if ~exist([PathName FileName],'file')
        PathName = [UniqueStrings{idwhichUnique(i)} RestPathStr{i}]; %LoadedFromPath{i};
        if ~exist([PathName FileName],'file')
            UniqueStrings(idwhichUnique(i)) = inputdlg('Edit Pathname to suit your system:', 'Load from', 1, UniqueStrings(idwhichUnique(i)));
            PathName = [UniqueStrings{idwhichUnique(i)} RestPathStr{i}]; %LoadedFromPath{i};
        end
    end
    [PathName, FileName]
    newtracks = fun(FileName, PathName);
    tracks = [tracks newtracks];
    suppress_progressdlg = 0;
    progressdlg(i);
end
