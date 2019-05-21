% function [f] = LifeTimePlot(Tracks, type, event, Options)
%LIFETIMEPLOT Summary of this function goes here
%   Detailed explanation goes here
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
[type, Tracks, event]=DF.SetType(1);
[uniquetype, uniqueorder, cid] = unique(type,'stable');
DelTracks = zeros(length(type),1);
for i = 1:length(uniquetype)
    if ~any(event(cid==i)) %find all types without events and remove their tracks
        DelTracks = DelTracks | cid==i;
    end
end
if  any(DelTracks)
    Tracks(DelTracks) = [];
    event(DelTracks) = [];
    type(DelTracks) = [];
    [uniquetype, uniqueorder, cid] = unique(type,'stable');
end
duration = nan(size(Tracks));
for i = 1:length(Tracks)
    duration(i) = abs(Tracks(i).X(end)-Tracks(i).X(1));
end
figure
hold on
for i = 1:length(uniqueorder)
    ecdf(duration(i==cid),'Function','cdf', ...
        'Censoring',~event(i==cid),'Bounds','on');
end
handles = get(gca, 'Children');
legend(handles(3:3:length(handles)), fliplr(uniquetype));
xlabel(['Lifetime [' Options.lPlot_XVar.str ']'])