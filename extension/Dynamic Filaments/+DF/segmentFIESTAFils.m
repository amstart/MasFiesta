function [Objects, Tracks] = SegmentFils(Options)
hDFGui = getappdata(0,'hDFGui');
Tracks=struct('Name', [], 'File', [], 'Type', [], 'Data', [NaN NaN NaN NaN], 'Velocity', nan(2,1), ...
    'Event', [NaN], 'DistanceEventEnd', [NaN]);  %these are required for the SetTable function to work upon startup
tagnum=4;
Objects = getappdata(hDFGui.fig,'Objects');
track_id=1;
progressdlg('String','Creating Tracks','Min',0,'Max',length(Objects));
for n = 1:length(Objects) 
    Objects(n).Duration = 0;
    Objects(n).Disregard = 0;
    DynResults=Objects(n).DynResults;
    includepoints = ones(size(DynResults,1), 1);
    if ~Options.cIncludeUnclearPoints.val
        includepoints = includepoints & Objects(n).Tags(:,1)~=8;
        includepoints = includepoints & Objects(n).Tags(:,1)~=7;
    end
    if ~Options.cIncludeNonTypePoints.val
        includepoints = includepoints & Objects(n).Tags(:,2)==0;
    end
    DynResults = DynResults(includepoints, :);
    t = DynResults(:,2);
    d = DynResults(:,3);
    intensity=fJKPlotIntensity(Objects(n),Options.eIevalLength.val,Options.cUsePosEnd.val+1);
    if isfield(Objects(n).Custom, 'IntensityPerMAP')
        intensity = intensity(DynResults(:,4))./Objects(n).Custom.IntensityPerMAP; %DynResults(:,4) is just a vector telling you in which rows 
    else
        intensity = intensity(DynResults(:,4));                                    %of the original data the row data can be found, i.e. 1 2 4.. 542 323
    end
    if isfield(Objects(n), 'CustomData') && ~isempty(Objects(n).CustomData)
        custom_data = [];
        for customfield = fields(Objects(n).CustomData)'
            if ~isempty(Objects(n).CustomData.(customfield{1}).read_fun)
                custom_data = [custom_data Objects(n).CustomData.(customfield{1}).read_fun(Objects(n), customfield, Options)];
            end
        end
        if ~isempty(custom_data)
            custom_data = custom_data(DynResults(:,4), :);  
            has_custom_data = 1;
        else
            custom_data = nan(size(t));
            has_custom_data = 0;
        end
    else
        custom_data = nan(size(t));
        has_custom_data = 0;
    end
    autotags = ones(size(t));
    ddiff = diff(d);
    cumdiff = 0;
    start = 1;
    counter = 0;
    for m=1:size(ddiff)
        if ddiff(m)>max(0, Options.eMinXChange.val)
            cumdiff=0;
            start=m+1;
            counter = 0;
        else
            counter = counter+1;
            cumdiff=cumdiff+ddiff(m);
        end
        if cumdiff<-Options.eMinDist.val&&(m==length(ddiff)||all(-cumdiff*Options.eMaxRebound.val>ddiff(m+1:min(m+counter,length(ddiff)))))
            autotags(start:m+1)=4;
        end
    end
    segmentstart=1;
    segmenti=1;
    segtagauto=nan(30,4);
    v=DF.CalcVelocity([t d]);
    tagstocheck=1:length(d);
    for m=tagstocheck(2:end-1)
        if autotags(m)==tagnum
             %creation of tracks based on tagging
            if autotags(m-1)~=tagnum&&autotags(m-1)~=tagnum+0.1 %untagged track creation
                autotags(m)=tagnum+0.1;
                segtagauto(segmenti, 1:4)=[segmentstart m autotags(m-1)+0.9 d(m)];
                segmentstart=m;
                segmenti=segmenti+1;
            end
            if autotags(m+1)~=tagnum&&d(segmentstart) %tagged track creation
                autotags(m)=tagnum+0.9;
                segtagauto(segmenti, 1:4)=[segmentstart m autotags(m) d(m)];
                segmentstart=m+1;
                segmenti=segmenti+1;
            end
        end
    end
    segtagauto(segmenti, 1:4)=[segmentstart tagstocheck(end) autotags(tagstocheck(end)) d(end)]; %add last segment
    segtagauto=segtagauto(~isnan(segtagauto(:,1)), :); %remove unused rows
    [segtagauto, autotags] = find_borders_and_pauses(segtagauto, autotags, v, t, d, Options);
    velocity=nan(size(segtagauto,1),1);
    is_tagged=false(size(segtagauto,1),1);
    segtagauto=segtagauto(segtagauto(:,1)<segtagauto(:,2),:); %remove nonsense tracks
    for m=2:size(segtagauto,1)
        if segtagauto(m,1)==segtagauto(m-1,1)||segtagauto(m,2)==segtagauto(m-1,2)
            segtagauto(m,1)=0; %remove double tracks
        end
    end
    segtagauto = [segtagauto zeros(size(segtagauto,1), 2)];
    for m=1:size(segtagauto,1)
        starti = segtagauto(m,1);
        endi = segtagauto(m,2);
        if floor(segtagauto(m,3))~=tagnum  %remove points too close to seed (plus ends only)
            if d(endi)<Options.eDisregard.val %remove growing tracks ending below disregard threshold
                continue
            end
            if min(d(starti:endi))<Options.eDisregard.val
                for id=starti:endi
                    if d(id)<Options.eDisregard.val
                        lastid = id;
                    end
                end
                Objects(n).Disregard = Objects(n).Disregard + t(lastid) - t(starti);
                starti = lastid;
                segtagauto(m,1) = lastid;
            end
        else %remove shrinking tracks starting below rescue threshold
            if d(starti)<Options.eRescueCutoff.val
                continue
            end
        end
        if starti==endi
            warning(['track only one frame long:' Objects(n).Name]);
            continue
        end
        segframes=(starti:endi)';
        segvel=v(segframes); %why, see Calcvelocity()
        segt=t(segframes);
        segd=d(segframes);
        Tracks(track_id).Name=Objects(n).Name;
        Tracks(track_id).MTIndex = n;
        Tracks(track_id).TrackIndex= track_id;
        Tracks(track_id).File=Objects(n).File;
        Tracks(track_id).Type=Objects(n).Type;
        Tracks(track_id).Duration=segt(end)-segt(1);
        Objects(n).Duration=Objects(n).Duration+Tracks(track_id).Duration;
        Tracks(track_id).Event=segtagauto(m,3);
        Tracks(track_id).DistanceEventEnd=segd(end);
        Tracks(track_id).Data=[segt segd segvel intensity(segframes) autotags(segframes) segframes custom_data(segframes, :)];
        Tracks(track_id).XEventStart=Tracks(track_id).Data(1,:);
        Tracks(track_id).XEventEnd=Tracks(track_id).Data(end,:);
        if m==1 || mod(Tracks(track_id-1).Event,1)-0.85<0
            Tracks(track_id).PreviousEvent=0;
            Tracks(track_id).XEventStart(:)=nan;
        else
            Tracks(track_id).PreviousEvent=1;
        end
        if mod(Tracks(track_id).Event,1)-0.85<0
            Tracks(track_id).XEventEnd(:)=nan;
        end
        
        Tracks(track_id).end_first_subsegment = length(segt);
        Tracks(track_id).start_last_subsegment = length(segt);
        is_tagged(m)=floor(segtagauto(m,3))==tagnum;
        [~, Tracks(track_id).minindex] = min(segvel);
        if Options.eSubStart.val && is_tagged(m)
            Tracks(track_id).end_first_subsegment = FindSubsegments(segvel, 1, Options.eSubStart.val, Tracks(track_id).minindex, Options.cAbsVelocity);
        end
        if Options.eSubEnd.val && is_tagged(m)
            Tracks(track_id).start_last_subsegment = FindSubsegments(segvel, -1, Options.eSubEnd.val, Tracks(track_id).minindex, Options.cAbsVelocity);
        end
        if m~=1
            subevent = Tracks(track_id-1).start_last_subsegment;
            if ~subevent
                subevent = starti;
            else
                subevent = Tracks(track_id-1).Data(subevent,6);
            end
            withFrames = Tracks(track_id-1).Data(1,6):endi;
            Tracks(track_id-1).WithTrackAfter=[t(withFrames)-t(subevent), d(withFrames)-d(subevent), v(withFrames), intensity(withFrames)]; %why, see Calcvelocity()
        elseif track_id>1
            Tracks(track_id-1).WithTrackAfter=nan(1,7);
        end
        Tracks(track_id).HasIntensity=any(intensity(starti:endi));
        segtagauto(m, 5)=track_id;
        segtagauto(m, 4)=Tracks(track_id).DistanceEventEnd;
        tmp_fit = polyfit(segt,segd,1);
        velocity(m) = tmp_fit(1);
        Tracks(track_id).Velocity=velocity(m);
        Tracks(track_id).Startendvel=(segd(end) - segd(1))/(segt(end) - segt(1));
        Tracks(track_id).Selected=0;
        Tracks(track_id).HasCustomData = has_custom_data;
        track_id=track_id+1;
    end
    Tracks(track_id-1).WithTrackAfter=nan(1,7);
    Objects(n).TrackIds = segtagauto(:,5);
    Objects(n).SegTagAuto=segtagauto;
    Objects(n).Velocity(1)=nanmean(velocity(~is_tagged));
    Objects(n).Velocity(2)=nanmean(velocity(is_tagged));
    progressdlg(n);
end


function [segtagauto, autotags] = find_borders_and_pauses(segtagauto, autotags, v, t, d, Options)
for m=1:size(segtagauto,1) %crop/extend beginning of tracks
    if floor(segtagauto(m,3))~=4
        continue
    end
    [~, minv] = min(v(segtagauto(m,1):segtagauto(m,2)));
    for k=segtagauto(m,1)+minv-1:-1:3 %loop through track, beginning at point with maximum shrinkage velocity (thought to be definitively part of the segment)
        if t(k)-t(k-1)> Options.eMaxTimeDiff.val %if too much time passes
            segtagauto(m,1)=k;
            if m~=1
                segtagauto(m-1,2)=k-1;
                segtagauto(m-1,3)=segtagauto(m-1,3)-0.1;
            end
            break
        elseif v(k)>-Options.eMinXChange.val %find growing step (above 0), then set beginning of track, unless...
            breaking = checkwhethercut(segtagauto, v(k+1), (d(k+1)-d(k-1))/(t(k+1)-t(k-1)), (d(k+1)-d(k-2))/(t(k+1)-t(k-2)), Options);
            if breaking
                segtagauto(m,1)=k;
                if m~=1
                    segtagauto(m-1,2)=k;
                end
                break
            else
                autotags(k) = 8; %is a pause
            end
        end
    end
end
for m=1:size(segtagauto,1) %crop/extend end of tracks
    if floor(segtagauto(m,3))~=4
        continue
    end
    [~, minv] = min(v(segtagauto(m,1):segtagauto(m,2)));
    for k=segtagauto(m,1)+minv-1:length(d)-1 %loop through track, beginning at point with maximum shrinkage velocity (thought to be definitively part of the segment)
        if t(k+1)-t(k)> Options.eMaxTimeDiff.val %if too much time passes
            segtagauto(m,2)=k;
            segtagauto(m,3)=segtagauto(m,3)-0.1; %censor event
            if m~=size(segtagauto,1)
                segtagauto(m+1,1)=k+1;
            end
            break
        elseif v(k)>-Options.eMinXChange.val %find growing step (above 0), then set beginning of track, unless...
            breaking = checkwhethercut(segtagauto, v(k-1), (d(k+1)-d(k-1))/(t(k+1)-t(k-1)), (d(k+2)-d(k-1))/(t(k+2)-t(k-1)), Options);
            if breaking
                segtagauto(m,2)=k-1;
                if m~=size(segtagauto,1)
                    segtagauto(m+1,1)=k-1;
                end
                break
            else
                autotags(k-1) = 8; %is a pause
            end
        end
    end
end

function [breaking] = checkwhethercut(segtagauto, v1, v2, v3, Options) %v1 is velocity before the bump, v2 is velocity throughout the bump
% if v2/Options.eMinXFactor.val>v1
%     %... the filament shrinks heavily before that step
%     breaking = 1;
% else
    if v3/3<min(0,-Options.eMinXChange.val) && v2<-Options.eMinXChange.val
        breaking = 0;
    else
        breaking = 1;
    end
% end

function [borderindex] = FindSubsegments(velocity, step, bordervalue, minindex, cAbsVelocity)
if step > 0
    starti = 1;
else
    starti = length(velocity);
end
for i = starti:step:minindex
    if cAbsVelocity.val
        criterium = velocity(i) < -bordervalue;
    else
        criterium = velocity(i)/velocity(minindex) > bordervalue/100;
    end
    if  criterium
        if step > 0 
            borderindex = max(i, 1);
        else
            borderindex = min(i, starti);
        end
        break
    end
end
if isempty(i)
    borderindex = 0;
elseif i == minindex && isempty(borderindex)
    borderindex = minindex;
end