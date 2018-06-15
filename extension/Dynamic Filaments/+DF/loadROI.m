function [Objects] = loadROI(FileName, PathName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if iscell(FileName)
    count = length(FileName);
else
    count = 1;
end
for i = 1:count
    if iscell(FileName)
        filename = FileName{i};
    else
        filename = FileName;
    end
    tmpstruc = ReadImageJROI([PathName filename]);
    ROI = tmpstruc.mnCoordinates;
    [~, ~, ic] = unique(ROI,'rows','stable');
    h = accumarray(ic, 1);                              % Count Occurrences
    maph = h(ic);
    ROI = [ROI maph-1];
    ROI = unique(ROI,'rows','stable');
    Objects(i).Name = [PathName filename];
    Objects(i).File = PathName;
    Objects(i).Comments = '';
    Objects(i).Results = ROI;
    Objects(i).Velocity = nan;
    Objects(i).CustomData = [];
    Objects(i).SegTagAuto = nan(1,5);
    Objects(i).Type = 'patch';
end
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
OldObjects = getappdata(hDynamicFilamentsGui.fig,'Objects');
if ~isempty(OldObjects)
    Objects = [OldObjects Objects];
end
setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
set(hDynamicFilamentsGui.cUsePosEnd, 'Enable', 'off');
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);
DF.SetTable()