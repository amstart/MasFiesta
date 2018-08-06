function [Objects] = loadTIF(FileName, PathName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if iscell(FileName)
    count = length(FileName);
else
    count = 1;
end
index = 1;
for i = 1:count
    if iscell(FileName)
        filename = FileName{i};
    else
        filename = FileName;
    end
    data = csvread([PathName 'flushs.csv']);
    pfile = imread([PathName filename])>0;
    pfile(data(:,2),:) = 0;
    tflushs = data(:,1:2)';
    outlines = bwboundaries(pfile);
    for j = 1:length(outlines)
%     [~, ~, ic] = unique(ROI,'rows','stable');
%     h = accumarray(ic, 1);                              % Count Occurrences
%     maph = h(ic);
%     ROI = [ROI maph-1];
%     ROI = unique(ROI,'rows','stable');        
        results = outlines{j};
        Objects(index).Name = [filename(1:end-4) ' ' num2str(mean(results(:,1)), 4) ' ' num2str(mean(results(:,2)), 4)];
        Objects(index).File = [PathName filename];
        Objects(index).LoadedFromPath = PathName;
        Objects(index).LoadedFromFile = filename;
        start = min(results(:,1));
        diff_toflush = (tflushs - start)>0;
        [~, first_positive] = max(diff_toflush(:));
        if mod(first_positive, 2) == 0 
            Objects(index).Type = 'flushin';
        else
            Objects(index).Type = 'flushout';
        end
        Objects(index).Concentration = data(ceil(first_positive/2),3);
        Objects(index).KCl = data(ceil(first_positive/2),4);
        Objects(index).Comments = '';
        Objects(index).Results = [results(:,1) results];
        Objects(index).Velocity = nan;
        Objects(index).CustomData = [];
        Objects(index).TrackIds = [];
        index = index + 1;
    end
end
hDFGui = getappdata(0,'hDFGui');
OldObjects = getappdata(hDFGui.fig,'Objects');
if ~isempty(OldObjects)
    Objects = [OldObjects Objects];
end
setappdata(hDFGui.fig,'Objects',Objects);
set(hDFGui.cUsePosEnd, 'Enable', 'off');
setappdata(0,'hDFGui',hDFGui);
DF.SetTable()