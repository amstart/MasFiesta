function [Objects, Tracks] = segmentPatchesLines(Options)
%PREPAREPATCHES Summary of this function goes here
%   Detailed explanation goes here
hDynamicFilamentsGui = getappdata(0,'hDFGui');
Tracks=struct('Name', [], 'File', [], 'Type', [], 'Data', [NaN NaN NaN NaN], 'Velocity', nan(2,1), ...
    'Event', [NaN], 'DistanceEventEnd', [NaN]);  %these are required for the SetTable function to work upon startup
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
track_id=1;
progressdlg('String','Creating Tracks','Min',0,'Max',length(Objects));
for n = 1:length(Objects) 
    Objects(n).Duration = 0;
    Objects(n).Disregard = 0;
    d = Objects(n).Results(:,1);
    t = Objects(n).Results(:,2);
    edge = Objects(n).Results(:,3);
    tdiff = diff(t);
    trackid = ones(length(t),1)*track_id;
    for m = 1:length(trackid)-1
        if ~tdiff(m)
            trackid(m+1:end) = trackid(m+1:end)+1;
        end
    end
    [objecttracks, ia] = unique(trackid, 'stable');
    for m=1:length(ia)
        trackid = ia(m);
        if m+1>length(ia)
            endi = length(t);
        else
            endi = ia(m+1)-1;
        end
        segt = t(ia(m):endi);
        segd = d(ia(m):endi);
        segedge = edge(ia(m):endi);
        if segt(1) > segt(end)
            segt=flipud(segt);
            segd=flipud(segd);
        end
        segvel=DF.CalcVelocity([segt segd]); %why, see Calcvelocity()
        Tracks(track_id).Name=Objects(n).Name;
        Tracks(track_id).MTIndex = n;
        Tracks(track_id).TrackIndex= trackid;
        Tracks(track_id).File=Objects(n).File;
        Tracks(track_id).Type=Objects(n).Type;
        Tracks(track_id).Duration=segt(end)-segt(1);
        Objects(n).Duration=Objects(n).Duration+Tracks(track_id).Duration;
        Tracks(track_id).PreviousEvent=nan;
        Tracks(track_id).end_first_subsegment = 0;
        Tracks(track_id).start_last_subsegment = 0;
        [~, Tracks(track_id).minindex] = min(segvel);
        Tracks(track_id).DistanceEventEnd=segd(end);
        Tracks(track_id).Data=[segt segd segvel segedge];
        Tracks(track_id).XEventStart=Tracks(track_id).Data(1,:);
        Tracks(track_id).XEventEnd=Tracks(track_id).Data(end,:);
        Tracks(track_id).Event=nan;
        Tracks(track_id).HasIntensity=0;
        tmp_fit = polyfit(segt,segd,1);
        velocity(m) = tmp_fit(1);
        Tracks(track_id).Velocity=velocity(m);
        Tracks(track_id).Selected=0;
        Tracks(track_id).HasCustomData = nan;
        track_id=track_id+1;
    end
    Objects(n).TrackIds=objecttracks;
    Objects(n).Velocity=nanmean(velocity);
    progressdlg(n);
end