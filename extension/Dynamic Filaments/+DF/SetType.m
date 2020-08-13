function [type, Tracks, event, orderid]=SetType(PlotGrowingTags, varargin) %PlotGrowingTags is needed because of the event plot
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
Tracks = getappdata(hDFGui.fig,'Tracks');
if Options.cOnlySelected.val
    Objects = getappdata(hDFGui.fig,'Objects');
    selected=get(hDFGui.lSelection,'Value');
    selected=unique(selected);
    selected=selected(logical(selected));
    Objects = Objects(selected);
    selected_tracks = [];
    for m = 1:length(Objects)
        selected_tracks = vertcat(selected_tracks, Objects(m).TrackIds');
    end
    selected_tracks = unique(selected_tracks);
    Tracks = Tracks(selected_tracks(logical(selected_tracks)));
end
type={Tracks.Type};
event=[Tracks.Event];
shrinks=[Tracks.Shrinks];
distance_event_end=[Tracks.DistanceEventEnd];
file={Tracks.File};
track_id=1:length(type);
for i=1:length(type)
    if shrinks(i) == PlotGrowingTags || size(Tracks(i).Data, 1) < Options.eMinLength.val
        track_id(i)=0;
        continue
    end
    if Tracks(i).Duration < Options.eMinDuration.val && Options.cPlotGrowingTracks.val == 1 
        track_id(i)=0;
        continue
    end
    if length(Tracks(i).FitData) == 1 && Options.cSwitch.val
        track_id(i)=0;
        continue
    end
    if Options.cPoolMAPs.val
        type{i}=strrep(type{i}, '+Ase1', '');
        type{i}=strrep(type{i}, '-Ase1', '');
    end
    type{i}=strrep(type{i}, 'single400', 'single');
    if shrinks(i)
        type{i}=[type{i} ' \downarrow'];
    else
        type{i}=[type{i} ' \uparrow'];
    end
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
    if Tracks(i).Shrinks && distance_event_end(i) < Options.eRescueCutoff.val
        event(i) = 0;
    end
    if Tracks(i).CensoredEvent
        event(i)= event(i) * 2; %events which had not been recorded
    end
    if event(i) && Options.cPlotEventsAsSeperateTypes.val
        type{i}=[type{i} '*'];
    end
end
track_id = track_id(logical(track_id));
Tracks = Tracks(track_id);
event = event(track_id);
type = type(track_id);
file = file(track_id);

if ~Options.cSwitch.val
xcolumn = Options.lPlot_XVar.val;
ycolumn = Options.lPlot_YVar.val;
zcolumn = Options.lPlot_ZVar.val;
else
xcolumn = Options.lPlot_XVarT.val;
ycolumn = Options.lPlot_YVarT.val;
zcolumn = Options.lPlot_ZVarT.val;
end

if Options.mXReference.val == 5
    if ycolumn == 3
        for i=1:length(Tracks)
            Tracks(i).Data(:,3,1) = Tracks(i).Data(:,3,1)-Tracks(i).Velocity;
        end
    else
        return
    end
end

if ~Options.cSwitch.val
for i=1:length(Tracks)
    d = Tracks(i).Data;
    if length(d) > 1
        Tracks(i).Y = d(d(:,2)>Options.eRescueCutoff.val,ycolumn);
        Tracks(i).X = d(d(:,2)>Options.eRescueCutoff.val,xcolumn);
        Tracks(i).Z = d(d(:,2)>Options.eRescueCutoff.val,zcolumn);
    else
        Tracks(i).X = nan;
        Tracks(i).Y = nan;
        Tracks(i).Z = nan;
    end
end
else
for i=1:length(Tracks)
    if length(Tracks(i).FitData) > 1
        d1 = fitFrame.getPlotData(Tracks(i), Options.lPlot_XVardim.val);
        d2 = fitFrame.getPlotData(Tracks(i), Options.lPlot_YVardim.val);
        d3 = fitFrame.getPlotData(Tracks(i), Options.lPlot_ZVardim.val);
        select = d1(:,7)<-500 | isnan(d1(:,7)) | d1(:,3) < 2;
        select(end-9:end) = 0;
        select(Tracks(i).Data(:,2)<500) = 0;
        select(find(select==0,1):end) = 0;
        Tracks(i).X = d1(select,xcolumn);
        Tracks(i).Y = d2(select,ycolumn);
        Tracks(i).Z = d3(select,zcolumn);
    else
        Tracks(i).Y = nan;
        Tracks(i).X = nan;
        Tracks(i).Z = nan;
    end
%     Tracks(i).X(Tracks(i).Z < 5) = nan;
end
end

if (xcolumn == 3 && Options.lMethod_TrackValue.val==7) || (ycolumn == 3 && Options.lMethod_TrackValueY.val==7) 
    for i=1:length(Tracks)
        [tmp_fit] = polyfit(Tracks(i).Data(:,1,1),Tracks(i).Data(:,2),1,1);
        Tracks(i).Velocity = tmp_fit(1);
    end
end
if nargin > 1
    switch varargin{1}
        case 'file'
            [~, ~, orderid] = unique(file);
    end
end