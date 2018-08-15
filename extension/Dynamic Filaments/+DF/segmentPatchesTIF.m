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
    Objects(n).TrackIds = [];
    Objects(n).Duration = 0;
    Objects(n).Disregard = 0;
    if isempty(Objects(n).Results)
        continue
    end
    d = Objects(n).Results(:,3);
    t = Objects(n).Results(:,2);
    oldframes = Objects(n).Results(:,1);
%     [~, minid] = min(oldframes);
    id = shifttomiddle(oldframes,n);
    t = circshift(t, [-id 0]);
    frames = circshift(oldframes, [-id 0]);
    d = circshift(d, [-id 0]);
    tdiff = diff(t);
    ddiff = diff(d);
    start = 1;
    auto = [];
    [~,maxid] = max(t);
    inside = d(start)-d(end);
    direction = tdiff(find(tdiff,1,'first'));
    tags = zeros(size(t));%4==nucleation/separation
    tdiffmin = 3;
    tdiffcurrent = 0;
    tdiffaim = tdiffmin+50*rand();
    justsetverylast = 0;
    for f = 1:length(tdiff)
        if justsetverylast
            justsetverylast = 0;
            start = f + 1;
            continue
        end
        tdiffcurrent = tdiffcurrent + tdiff(f);
        justsetlast = 0;
        if frames(f+1)==Objects(n).LastFrame
            auto = vertcat(auto, [start f+1 1 d(f) frames(f)]);
            direction = -direction;
            justsetverylast = 1;
            justsetlast = 1;
        elseif tdiff(f)*direction < 0
            auto = vertcat(auto, [start f+1 4 d(f) frames(f)]);
            direction = -direction;
            justsetlast = 1;
        elseif abs(tdiffcurrent) > tdiffaim
            auto = vertcat(auto, [start f+1 2 d(f) frames(f)]);
        elseif f == length(tdiff)
            if t(end)-t(start) == 0
                auto(end,2:5) = [f+1 -1 d(f) frames(f)];
            else
                auto = vertcat(auto, [start f+1 -1 d(f) frames(f)]);
            end
        else
            continue
        end
        start = f + 1;
        tdiffcurrent = 0;
        tdiffaim = tdiffmin+17*rand();
%         if justsetlast && abs(auto(end))==1%remove too short segments
%             if abs(diff(t(auto(end, 1:2))))<tdiffmin
%                 if size(auto,1)>1
%                     auto(end-1, 2) = auto(end, 2);
%                     auto(end,:) = [];
%                 end
%             end
%         end
    end
    velocity = [];
    for m=1:size(auto, 1)
        segt = t(auto(m,1):auto(m,2));
        segd = d(auto(m,1):auto(m,2));
        segtags = frames(auto(m,1):auto(m,2));
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
        if Objects(n).isflushin && m == size(auto,1)
            segt = vertcat(t(1),segt);
            segd = vertcat(d(1),segd);
            segtags = vertcat(frames(1),segtags);
        end
        Objects(n).TrackIds=[Objects(n).TrackIds track_id];
        segvel=DF.CalcVelocity([segt segd]); %why, see Calcvelocity()
        Tracks(track_id).Name=Objects(n).Name;
        Tracks(track_id).MTIndex = n;
        Tracks(track_id).TrackIndex= m;
        Tracks(track_id).GlobalTrackIndex= track_id;
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
%         tmp_fit = polyfit(segt,segd,1);
        velocity(m) = abs((segd(end)-segd(1))/(segt(end)-segt(1)));
        Tracks(track_id).Velocity=velocity(m);
        Tracks(track_id).Selected=0;
        Tracks(track_id).HasCustomData = nan;
        track_id=track_id+1;
    end
% %     auto(auto(:,6)==0,:) = [];
%     Objects(n).TrackIds=auto(:,6);
    Objects(n).Velocity=nanmean(velocity);
    Objects(n).auto=[auto velocity'];
    progressdlg(n);
end

function shiftby = shifttomiddle(data,n)
minval = min(data);
vec = data==minval;
if sum(vec)==2 && vec(1) == vec(end)
    shiftby = 0;
    return
end
N = 11;
vec = movmean(vec([(end-floor(N./2)+1):end 1:end 1:(ceil(N./2)-1)]), N, 'Endpoints', 'discard');
N = 5;
vec = movmean(vec([(end-floor(N./2)+1):end 1:end 1:(ceil(N./2)-1)]), N, 'Endpoints', 'discard');
N=3;
vec = movmean(vec([(end-floor(N./2)+1):end 1:end 1:(ceil(N./2)-1)]), N, 'Endpoints', 'discard');
[~, shiftby] = max(vec);


function middle = findmiddle(t,id, n)
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