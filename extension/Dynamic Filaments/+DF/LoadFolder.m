function LoadFolder(varargin)
global DFDir
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
% answer = questdlg('Use link file or open all .mat files within folder which say "dynamics"?', 'Method', 'Link','Folder','Link' );
try
    folder = uigetdir(DFDir, 'Select the folder');
catch 
    folder = uigetdir('','Select the folder');
end
DFDir = folder;
if folder~=0
    fileList = getAllFiles(folder);
    fileList = fileList(~cellfun(@isempty, strfind(fileList, '.mat'))); %only mat files
    fileList = fileList(~cellfun(@isempty, strfind(fileList, 'dynamics'))|~cellfun(@isempty, strfind(fileList, 'Dynamics'))); %only dynamics
    numfiles = length(fileList);
    progressdlg('String','Loading Files','Min',0,'Max',numfiles,'Parent',hDynamicFilamentsGui.fig);
    for i = 1:numfiles
        [PathName, FileName, ext] = fileparts(char(fileList(i)));
        DF.Load([filesep FileName ext],PathName);
        progressdlg(i);
    end
    UpdateOptions();
end
%     try
%         [FileLink, folder] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link',DFDir);
%     catch
%         [FileLink, folder] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link');        
%     end
