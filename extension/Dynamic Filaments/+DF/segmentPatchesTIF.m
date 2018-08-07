function [Objects, Tracks] = segmentPatchesLines(Options)
%PREPAREPATCHES Summary of this function goes here
%   Detailed explanation goes here
hDynamicFilamentsGui = getappdata(0,'hDFGui');
Tracks=struct('Name', [], 'File', [], 'Type', [], 'Data', [NaN NaN NaN NaN], 'Velocity', nan(2,1), ...
    'Event', [NaN], 'DistanceEventEnd', [NaN]);  %these are required for the SetTable function to work upon startup
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
track_id=1;
progressdlg('String','Creating Tracks','Min',0,'Max',length(Objects));
maxpause = 10;
for n = 1:length(Objects) 
    Objects(n).Duration = 0;
    Objects(n).Disregard = 0;
    d = Objects(n).Results(:,3);
    t = Objects(n).Results(:,2);
    [~, minid] = min(t);
    id = findmiddle(t,minid);
    t = circshift(t, [-id 0]);
    d = circshift(d, [-id 0]);
    tdiff = diff(t);
    ddiff = diff(d);
    start = 1;
    auto = [];
    [~,maxid] = max(t);
    inside = d(start)-d(end);
    direction = tdiff(find(tdiff,1,'first'));
    tags = ones(size(t));
    if tdiff(1) == 0
        tags(1:find(abs(tdiff)>0,1,'first')-1) = 0;
    end
    if tdiff(end) == 0
        tags(find(abs(tdiff)>0,1,'last'):end) = 0;
    end
%     todo = 1:length(tdiff);
    isgrowing = 1;
    for f = 1:length(tdiff)
%         if ~todo(f)
%             continue
%         end
        if f>1 && ddiff(f)==0
            tags(f+1)=1+tags(f);
        end
        if tags(f+1)>maxpause && f < length(tdiff)
            if isgrowing
                auto = vertcat(auto, [start f+2-maxpause nan]);
                start = f + 1;
                isgrowing = 0;
            else
                start = f+1;
                continue
            end
        else
            isgrowing = 1;
        end
        if tdiff(f)*direction < 0
            auto = vertcat(auto, [start f nan]);
            direction = -direction;
            start = f + 1;
        elseif f == length(tdiff)
            auto = vertcat(auto, [start f+1 nan]);
        end
    end
    for m=1:size(auto, 1)
        segt = t(auto(m,1):auto(m,2));
        segd = d(auto(m,1):auto(m,2));
        segtags = tags(auto(m,1):auto(m,2));
        if t(auto(m,1)) > t(auto(m,2))
            segt = flipud(segt);
            segd = flipud(segd);
            segtags = flipud(segtags);
            auto(m,1:2) = [auto(m,2) auto(m,1)];
        end
%         if strcmp(Objects(n).Type, 'flushout')
%             startend = find(diff(segt),1,'first'):find(diff(segt),1,'last');
%         else
%             startend = 1:find(diff(segt),1,'last');
%         end
%         segt = segt(startend);
%         segd = segd(startend);
%         segtags = segtags(startend);
        if isempty(segt)
            ['empty:' Objects(n).Name ' ' num2str(t(auto(m,1):auto(m,2))')]
            auto(m,3) = 0;
            continue
        end
        auto(m,3) = track_id;
        segvel=DF.CalcVelocity([segt segd]); %why, see Calcvelocity()
        Tracks(track_id).Name=Objects(n).Name;
        Tracks(track_id).MTIndex = n;
        Tracks(track_id).TrackIndex= m;
        Tracks(track_id).File=Objects(n).File;
        Tracks(track_id).Type=Objects(n).Type;
        Tracks(track_id).Duration=segt(end)-segt(1);
        Objects(n).Duration=Objects(n).Duration+Tracks(track_id).Duration;
        Tracks(track_id).end_first_subsegment = 0;
        Tracks(track_id).start_last_subsegment = 0;
        [~, Tracks(track_id).minindex] = min(segvel);
        Tracks(track_id).DistanceEventEnd=segd(end);
        Tracks(track_id).Data=[segt segd segvel segtags];
        Tracks(track_id).XEventStart=Tracks(track_id).Data(1,:);
        Tracks(track_id).XEventEnd=Tracks(track_id).Data(end,:);
        Tracks(track_id).Event=nan;
        Tracks(track_id).HasIntensity=0;
        tmp_fit = polyfit(segt,segd,1);
        velocity(m) = abs(tmp_fit(1));
        Tracks(track_id).Velocity=velocity(m);
        Tracks(track_id).Selected=0;
        Tracks(track_id).HasCustomData = nan;
        track_id=track_id+1;
    end
    auto(auto(:,3)==0,:) = [];
    Objects(n).TrackIds=auto(:,3);
    Objects(n).Velocity=nanmean(velocity);
    progressdlg(n);
end

function middle = findmiddle(t,id)
isatend = 0;
if id==1 && t(end)-t(id)==0
    tmp = t-t(id);
    lastnonzero = find(flipud(tmp),1,'first');
    id = length(t) - lastnonzero+2;
    isatend = 1;
end
afterlast = id;
for frame = id+1:id+length(t)
    f = frame;
    if f > length(t)
        isatend = 1;
        f = f-length(t);
    end
    if t(id)~=t(f)
        afterlast = f;
        break
    end
end
if isatend
    middle = ceil(mean([id afterlast-1+length(t)]));
    if middle > length(t)
        middle = middle - length(t);
    end
else
    middle = round(mean([id afterlast-1]));
end