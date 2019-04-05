function [type, Tracks, event]=SetType(PlotGrowingTags) %PlotGrowingTags is needed because of the event plot
if PlotGrowingTags 
    plottag = 1;
else
    plottag = 4; %this is a code (see DF.SegmentFIESTAFils.m))
end
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
if ~isempty(strfind(Options.lPlot_XVar.print, 'Ase1')) || ~isempty(strfind(Options.lPlot_YVar.print, 'Ase1'))
    OnlyWithIntensity = 1;
else
    OnlyWithIntensity = 0;
end
if Options.lPlot_XVar.val > 6 || Options.lPlot_YVar.val > 6 
    OnlyWithCustomData = 1;
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
        if OnlyWithIntensity
            if Tracks(i).HasIntensity==0
                track_id(i)=0;
                continue
            end
        end
        if OnlyWithCustomData
            if Tracks(i).HasCustomData==0
                track_id(i)=0;
                continue
            end
        end
        type{i}=[type{i} ' tag' num2str(event(i))];
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
            if abs(mod(event(i),1)-0.85)<0.1
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
track_id=track_id(logical(track_id));
type=type(track_id);
event=event(track_id);
Tracks=Tracks(track_id);