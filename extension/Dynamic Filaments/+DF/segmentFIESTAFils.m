function [Objects, tracks] = SegmentFils(Options)
hDFGui = getappdata(0,'hDFGui');
tracks=struct('Name', [], 'File', [], 'Type', [], 'Data', [NaN NaN NaN NaN], 'Velocity', nan(2,1), ...
    'Event', [NaN], 'DistanceEventEnd', [NaN]);  %these are required for the SetTable function to work upon startup
Objects = getappdata(hDFGui.fig,'Objects');
track_id = 0;
progressdlg('String','Creating tracks','Min',0,'Max',length(Objects));
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
    v=DF.CalcVelocity([t d]);
    a=[0; diff(v)./diff(t)];
    dmov = movsum([0; diff(d)],3);
    shrinks = dmov < - Options.eMinDist.val;
    shrinks = logical(movmedian(shrinks,5));
    changes = find(diff(shrinks))+1;
    tracks_shrinks = shrinks([1; changes]);
    tracks_direction = 1 - 2 * tracks_shrinks;
    for i = 1:length(changes) %this moves the changes maximum 2 frames backwards (movsum has kernel of 3 frames)
        for j = 1:2
            if (-tracks_direction(i)) * v(changes(i)) > tracks_direction(i) * Options.eMinXChange.val
                changes(i) = changes(i)-1;
            end
        end
    end

    disr = movmax(d - Options.eDisregard.val,5);
%     track_borders = [1; changes; length(shrinks)];
    track_starts = [1; changes];
    track_ends = [changes; length(shrinks)];
    for i = 1:length(tracks_shrinks)
        if tracks_shrinks(i)
            if disr(track_starts(i)) < 0
                track_starts(i) = nan;
                track_ends(i) = nan;
            end
            continue
        end
        lastbelowdisregard = find(disr(track_starts(i):track_ends(i))<0,1,'last');
        if ~isempty(lastbelowdisregard)
            if lastbelowdisregard == length(track_starts(i):track_ends(i))
                track_starts(i) = nan;
                track_ends(i) = nan;
            else
                track_starts(i) = track_starts(i)+lastbelowdisregard-1;
            end
        end
    end
    track_starts(isnan(track_starts)) = [];
    track_ends(isnan(track_ends)) = [];

    track_ids = track_id+(1:length(track_starts));
    for m = 1:length(track_starts)
        track_id = track_ids(m);
        track.Name=Objects(n).Name;
        track.MTIndex = n;
        track.TrackIndex = track_ids(m);
        track.File=Objects(n).File;
        track.Type=Objects(n).Type;
        track.isPause = 0;
        
        trackframes=(track_starts(m):(track_ends(m)))';
        if m == 1
            track.PreviousEvent=0;
        else
            track.PreviousEvent=1;
        end
        if diff(t(trackframes(1:2))) > Options.eMaxTimeDiff.val %in case there are frames missing
            trackframes(1) = [];
            track.PreviousEvent=0;
        end
        track.Event = 1;
        track.CensoredEvent = 0;
        if trackframes(end) == length(v)
            track.Event = 0;
        elseif diff(t(trackframes(end-1:end)+1)) > Options.eMaxTimeDiff.val
            track.CensoredEvent = 1;
        elseif diff(t(trackframes(end-1:end))) > Options.eMaxTimeDiff.val
            trackframes(end) = [];
            track.CensoredEvent = 1;
        end
        if length(trackframes) == 1
            warning(['track only one frame long:' Objects(n).Name]);
        end

        segvel=v(trackframes); %why, see Calcvelocity()
        segvel(1) = nan;
        segt=t(trackframes);
        segd=d(trackframes);
        
        track.Duration=segt(end)-segt(1);
        Objects(n).Duration=Objects(n).Duration+track.Duration;
        track.DistanceEventEnd=segd(end);
        track.Shrinks=logical(median(shrinks(trackframes)));
        if track.Shrinks && m > 2 && shrinks(trackframes(1)-3) %checks whether there was a pause
            tracks(track_id-1).Event = 0;
            tracks(track_id-1).isPause = 1;
            tracks(track_id-2).Event = 0;
            tracks(track_id-2).isPause = 1;
        end

        track.Data=[segt segd segvel intensity(trackframes) shrinks(trackframes) trackframes custom_data(trackframes, :)];
        try
            track.Data(:,13) = track.Data(:,9)./track.Data(:,2);
        catch
        end
        
        track.WithTrackAfter=nan(1,1,size(track.Data,2));
        if m > 1
            withFrames = tracks(track_id-1).Data(1,6):trackframes(end);
            tracks(track_id-1).WithTrackAfter = [t(withFrames)-t(trackframes(1)), d(withFrames)-d(trackframes(1)), v(withFrames), intensity(withFrames)]; 
        end
        velocity(m) = (segd(end) - segd(1))/(segt(end) - segt(1));
        track.Startendvel=velocity(m);
        track.Velocity=velocity(m);
        track.Selected=0;
        track.HasCustomData = has_custom_data;
        if track_id == 1
            tracks = track;
        else
            tracks(track_id) = track;
        end
    end
    Objects(n).TrackIds = track_ids;
    tracks_shrinks = [tracks(track_ids).Shrinks];
    Objects(n).Velocity(1)=nanmean(velocity(~tracks_shrinks));
    Objects(n).Velocity(2)=nanmean(velocity(tracks_shrinks));
    progressdlg(n);
end