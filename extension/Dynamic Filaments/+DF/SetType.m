function [type, Tracks, event, orderid]=SetType(PlotGrowingTags, varargin) %PlotGrowingTags is needed because of the event plot
if PlotGrowingTags 
    plottag = 1;
else
    plottag = 4; %this is a code (see DF.SegmentFIESTAFils.m))
end
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
if Options.lPlot_XVar.val > 6 || Options.lPlot_YVar.val > 6 
    OnlyWithCustomData = 0;
else
    OnlyWithCustomData = 0;
end
Tracks = getappdata(hDFGui.fig,'Tracks');
if Options.cOnlySelected.val
    Objects = getappdata(hDFGui.fig,'Objects');
    selected=get(hDFGui.lSelection,'Value');
    selected=unique(selected);
    selected=selected(logical(selected));
    Objects = Objects(selected);
    selected_tracks = [];
    for m = 1:length(Objects)
        selected_tracks = vertcat(selected_tracks, Objects(m).SegTagAuto(:,5));
    end
    selected_tracks = unique(selected_tracks);
    Tracks = Tracks(selected_tracks(logical(selected_tracks)));
end
type={Tracks.Type};
event=[Tracks.Event];
distance_event_end=[Tracks.DistanceEventEnd];
file={Tracks.File};
track_id=1:length(type);
xcolumn = Options.lPlot_XVar.val;
ycolumn = Options.lPlot_YVar.val;
for i=1:length(type)
    if hDFGui.mode == 2
        if floor(event(i))~=plottag || size(Tracks(i).Data, 1) < Options.eMinLength.val
            track_id(i)=0;
            continue
        end
        if Options.cPlotGrowingTracks.val == 1 && Tracks(i).Duration < Options.eMinDuration.val
            track_id(i)=0;
            continue
        end
%         if OnlyWithIntensity
%             if Tracks(i).HasIntensity==0
%                 track_id(i)=0;
%                 continue
%             end
%         end
        if OnlyWithCustomData
            if Tracks(i).HasCustomData==0 || size(Tracks(i).Data,2) < xcolumn || size(Tracks(i).Data,2) < ycolumn
                track_id(i)=0;
                continue
            end
        end
        type{i}=[type{i} ' tag' num2str(event(i))];
    end
    if Options.cPoolMAPs.val
        type{i}=strrep(type{i}, '+Ase1', '');
        type{i}=strrep(type{i}, '-Ase1', '');
    end
    type{i}=strrep(type{i}, 'single400', 'single');
    type{i}=strrep(type{i}, '4.8', '4');
    type{i}=strrep(type{i}, '4.9', '4');
    type{i}=strrep(type{i}, 'tag4', '\downarrow');
    type{i}=strrep(type{i}, '1.8', '1');
    type{i}=strrep(type{i}, '1.9', '1');
    type{i}=strrep(type{i}, 'tag1', '\uparrow');
    switch Options.lGroup.val
        case 1
            prepend = '';
        case 2
            splitstr = strsplit(file{i},'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}  ' \_ '];
            else
                prepend=[splitstr{2}  ' \_ '];
            end
        case 3
            splitstr = strsplit(file{i},'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}(7:8) ' \_ ' splitstr{2} ' \_ '];
            else
                prepend=[splitstr{2} ' \_ ' splitstr{1} ' \_ '];
            end
        case 4
            prepend = '';
            type{i} = 'everything';
    end
    type{i}=[prepend type{i}];
    if hDFGui.mode == 2
        if (distance_event_end(i)>Options.eRescueCutoff.val||floor(event(i))~=4)&&abs(mod(event(i),1)-0.85)<0.1
            if mod(event(i),1)-0.85<0
                event(i)=2; %events which had not been recorded
            else
                event(i)=1;
            end
            if Options.cPlotEventsAsSeperateTypes.val
                type{i}=[type{i} '*'];
            end
        else
            event(i)=0;
        end
    end
end
track_id = track_id(logical(track_id));
Tracks = Tracks(track_id);
event = event(track_id);
type = type(track_id);
file = file(track_id);

%old function preparexydata
if Options.mXReference.val == 5
    if ycolumn == 3
        for i=1:length(Tracks)
            Tracks(i).Data(:,3) = Tracks(i).Data(:,3)-Tracks(i).Velocity;
        end
    else
        return
    end
end
if Options.eSmoothX.val > 1
    for i=1:length(Tracks)
        Tracks(i).Data(:,xcolumn) = nanfastsmooth(Tracks(i).Data(:,xcolumn), Options.eSmoothX.val);
    end
end
if Options.eSmoothY.val > 1
    for i=1:length(Tracks)
        Tracks(i).Data(:,ycolumn) = nanfastsmooth(Tracks(i).Data(:,ycolumn), Options.eSmoothY.val);
    end
end
for i=1:length(Tracks)
%     if xcolumn >2 || ycolumn > 2
%         Tracks(i).Data = [Tracks(i).Data(1:end-1,1:2) + diff(Tracks(i).Data(:,1:2)) Tracks(i).Data(1:end-1,3:end)];
%     end
    Tracks(i).XEventEnd = Tracks(i).XEventEnd(xcolumn);
    Tracks(i).XEventStart = Tracks(i).XEventStart(xcolumn);
end
if get(hDFGui.lChoosePlot, 'Value') == 8
    for i=1:length(Tracks)
        Tracks(i).Data = Tracks(i).WithTrackAfter;
    end
else
    [Tracks, DelObjects] = SelectSubsegments(Tracks, Options);
    Tracks(DelObjects) = [];
    event(DelObjects) = [];
    type(DelObjects) = [];
end
for i=1:length(Tracks)
    Tracks(i).Y = Tracks(i).Data(:,ycolumn);
    Tracks(i).X = Tracks(i).Data(:,xcolumn);
end
if (xcolumn == 3 && Options.lMethod_TrackValue.val==7) || (ycolumn == 3 && Options.lMethod_TrackValueY.val==7) 
    for i=1:length(Tracks)
        [tmp_fit] = polyfit(Tracks(i).Data(:,1),Tracks(i).Data(:,2),1);
        Tracks(i).Subsegvel = tmp_fit(1);
    end
end
% Tracks = rmfield(Tracks, 'Data');
if nargin > 1
    switch varargin{1}
        case 'file'
            [~, ~, orderid] = unique(file);
        case 'colors'
            for i=1:length(Tracks)
                Tracks(i).Z = Tracks(i).Data(:,varargin{2});
            end
    end
end
for i=1:length(Tracks)
    Tracks(i).Z = Tracks(i).Data(:,1);
end


function [Tracks, DelObjects] = SelectSubsegments(Tracks, Options)
DelObjects = false(length(Tracks),1);
for i=1:length(Tracks)
    starti = Tracks(i).end_first_subsegment-1;
    endi = Tracks(i).start_last_subsegment;
    if ~starti || ~endi
        Tracks(i).Startendvel = nan;
    else
        Tracks(i).Startendvel = (Tracks(i).Data(endi,2)-Tracks(i).Data(starti,2))/(Tracks(i).Data(endi,1)-Tracks(i).Data(starti,1));
    end
end
switch Options.lSubsegment.val
    case 2
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment
                Tracks(i).Data = Tracks(i).Data(1:Tracks(i).end_first_subsegment,:);
            else
                DelObjects(i) = 1;
            end
        end
    case 3
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).Data = Tracks(i).Data(Tracks(i).end_first_subsegment:Tracks(i).start_last_subsegment,:);
            else
                DelObjects(i) = 1;
            end
        end
    case 4
        for i=1:length(Tracks)
            if Tracks(i).start_last_subsegment
                Tracks(i).Data = Tracks(i).Data(Tracks(i).start_last_subsegment:end,:);
            else
                DelObjects(i) = 1;
            end
        end
    case 5
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).Data = Tracks(i).Data(1:Tracks(i).start_last_subsegment,:);
            else
                DelObjects(i) = 1;
            end
        end
    case 6
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).Data = Tracks(i).Data(Tracks(i).end_first_subsegment:end,:);
            else
                DelObjects(i) = 1;
            end
        end
    case 7
        for i=1:length(Tracks)
            if Tracks(i).minindex > 1 && Tracks(i).minindex < size(Tracks(i).Data,1)
                Tracks(i).Data = Tracks(i).Data(Tracks(i).minindex:end,:);
            else
                DelObjects(i) = 1;
            end
        end
end
for i=1:length(Tracks)
    if isempty(Tracks(i).Data) || size(Tracks(i).Data,1) < 2
        DelObjects(i) = 1;
    end
end

