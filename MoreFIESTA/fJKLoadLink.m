function [ output ] = fJKLoadLink(FileName, PathName, fun)
%FJKLOADLINK Summary of this function goes here
%   Detailed explanation goes here
tmpstruc = load([PathName FileName]);
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
for i = 1:numfiles
    FileName = LoadedFromFile{i};
    try
        try
            PathName = [folder RestPathStr{i}]; %LoadedFromPath{i};
            fun(FileName, PathName);
        catch
            PathName = [UniqueStrings{idwhichUnique(i)} RestPathStr{i}]; %LoadedFromPath{i};
            fun(FileName, PathName);
        end
    catch
        UniqueStrings(idwhichUnique(i)) = inputdlg('Edit Pathname to suit your system:', 'Load from', 1, UniqueStrings(idwhichUnique(i)));
        PathName = [UniqueStrings{idwhichUnique(i)} RestPathStr{i}]; %LoadedFromPath{i};
        fun(FileName, PathName);
    end
    progressdlg(i);
end

