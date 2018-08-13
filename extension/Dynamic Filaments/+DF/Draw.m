function Draw(hDFGui)
Options = getappdata(hDFGui.fig,'Options');
cla(hDFGui.aPlot, 'reset');
cla(hDFGui.aVelPlot, 'reset');
cla(hDFGui.aIPlot, 'reset');
Tracks = getappdata(hDFGui.fig,'Tracks');
Objects = getappdata(hDFGui.fig,'Objects');
Selected=get(hDFGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    switch hDFGui.mode
        case 1
            drawPatch(hDFGui, Object, Tracks, Selected, Options, Objects);
        case 2
            drawFil(hDFGui, Object, Tracks, Selected, Options, Objects);
    end
end

function drawPatch(hDFGui, Object, Tracks, Selected, Options, Objects)
track_id=Object.TrackIds;
eSmoothY=str2double(get(hDFGui.eSmoothY, 'String'));

track_id=track_id(track_id>0);
if isempty(track_id)
    text(0.2,0.5,'No tracks available for current object.','Parent',hDFGui.aPlot,'FontWeight','bold','FontSize',16);
    return
end
tracks=Tracks(track_id);
[c1_vec, c2_vec] = DF.get_plot_vectors(Options, tracks, [1 2]);

set(hDFGui.fig, 'Name',['Dynamics: ' Object.Name '  (' Object.Comments ')']);
if ~isempty(track_id)
hold(hDFGui.aVelPlot,'on');
hold(hDFGui.aIPlot,'on');
hold(hDFGui.aPlot,'on');
axes(hDFGui.aPlot);
c = 'k';
tcol = 4;
for i=1:length(tracks)
    segtrack=tracks(i).Data;
    tseg=segtrack(:,tcol);
    if eSmoothY == 1
        dseg=segtrack(:,2);
        c2seg=segtrack(:, Options.lPlot_YVar.val);
        c1seg=segtrack(:, Options.lPlot_XVar.val);
    else
        dseg=nanfastsmooth(segtrack(:,2), eSmoothY);
        c2seg=nanfastsmooth(segtrack(:,Options.lPlot_YVar.val), eSmoothY);
        c1seg=nanfastsmooth(segtrack(:,Options.lPlot_XVar.val), eSmoothY);
    end
    d0=round(nanmean(segtrack(:,2)));
    t0=segtrack(round(size(segtrack,1)/2),tcol);
    if get(hDFGui.cshowTrackN,'Value');
        text(double(t0),double(max(segtrack(:,2))),num2str(track_id(i)));
    end
%     plot(hDFGui.aPlot,tseg(pauses),dseg(pauses),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor','c');
        plot(hDFGui.aPlot,tseg,tracks(i).Velocity(end).*(tseg-t0)+d0,'b-.');
    plot(hDFGui.aIPlot,tseg,repmat(c1_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aVelPlot,tseg,repmat(c2_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aPlot,tseg,dseg,'Color', c);
    plot(hDFGui.aVelPlot,tseg,c2seg,'Color', c);
    plot(hDFGui.aIPlot,tseg,c1seg,'Color', c);
end
xy=get(hDFGui.aPlot,{'xlim','ylim'});
set(hDFGui.aPlot,{'xlim','ylim'},xy);
legend(hDFGui.aPlot,'off');
xlabel(hDFGui.aPlot,'time [s]');
ylabel(hDFGui.aPlot,'distance to seed [nm]'); 
xlabel(hDFGui.aVelPlot,'time [s]');
ylabel(hDFGui.aIPlot, [Options.lPlot_XVar.print ' [' Options.lPlot_XVar.str ']']); 
xlabel(hDFGui.aIPlot,'time [s]');
ylabel(hDFGui.aVelPlot, [Options.lPlot_YVar.print ' [' Options.lPlot_YVar.str ']']); 
zoom(hDFGui.aPlot, 'on');
zoom(hDFGui.aVelPlot, 'on');
zoom(hDFGui.aIPlot, 'on');
linkaxes([hDFGui.aPlot,hDFGui.aIPlot, hDFGui.aVelPlot],'x')
end
for i=2:length(Selected)
    Object = Objects(Selected(i));
    tmp=Object.TrackIds;
    trackid=[track_id tmp(tmp>0)];
end
for i=1:length(Tracks)
    if ismember(i,track_id)
        Tracks(i).Selected=1;
    else
        Tracks(i).Selected=0;
    end
end
if isempty(tracks)
    text(0.2,0.5,'No data available for current object. You might need to press "Segment".','Parent',hDFGui.aPlot,'FontWeight','bold','FontSize',16);
end
setappdata(hDFGui.fig,'Tracks', Tracks);
setappdata(0,'hDFGui',hDFGui);


function drawFil(hDFGui, Object, Tracks, Selected, Options, Objects)
eSmoothY=str2double(get(hDFGui.eSmoothY, 'String'));
tagnum = 4;
cutoff=Options.eRescueCutoff.val;
track_id=Object.TrackIds;

track_id=track_id(track_id>0);
tracks=Tracks(track_id);
[c1_vec, c2_vec] = DF.get_plot_vectors(Options, tracks, [1 2]);
set(hDFGui.fig, 'Name',['Dynamics: ' Object.Name '  (' Object.Comments ')']);
modevents=mod(Object.SegTagAuto(Object.TrackIds>0,3),1);
if ~isempty(track_id)
hold(hDFGui.aVelPlot,'on');
hold(hDFGui.aIPlot,'on');
hold(hDFGui.aPlot,'on');
axes(hDFGui.aPlot);
for i=1:length(tracks)
    segtrack=tracks(i).Data;
    tseg=segtrack(:,1);
    if hDFGui.mode == 2
        pauses=find(segtrack(:,5)==8);
    else
        pauses = [];
    end
    if eSmoothY == 1
        dseg=segtrack(:,2);
        c2seg=segtrack(:, Options.lPlot_YVar.val);
        c1seg=segtrack(:, Options.lPlot_XVar.val);
    else
        dseg=nanfastsmooth(segtrack(:,2), eSmoothY);
        c2seg=nanfastsmooth(segtrack(:,Options.lPlot_YVar.val), eSmoothY);
        c1seg=nanfastsmooth(segtrack(:,Options.lPlot_XVar.val), eSmoothY);
    end
    d0=round(nanmean(segtrack(:,2)));
    t0=segtrack(round(size(segtrack,1)/2),1);
    if get(hDFGui.cshowTrackN,'Value');
        text(double(t0),double(max(segtrack(:,2))),num2str(track_id(i)));
    end
    plot(hDFGui.aPlot,tseg(pauses),dseg(pauses),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor','c');
    if floor(tracks(i).Event)==tagnum
        c='r';
        if size(dseg,1) < str2double(get(hDFGui.eMinLength, 'String'))
            c=[0.7 0.7 0.7];
        end
        if modevents(i)>0.85&&dseg(end)>cutoff
            plot(hDFGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
        elseif modevents(i)>0.7&&dseg(end)>cutoff
            plot(hDFGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
        end
    else
        c='k';
        if modevents(i)>0.85
            plot(hDFGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
        elseif modevents(i)>0.7
            plot(hDFGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
        end
    end
%         plot(hDFGui.aPlot,tseg,tracks(i).Velocity(end).*(tseg-t0)+d0,'b-.');
    plot(hDFGui.aIPlot,tseg,repmat(c1_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aVelPlot,tseg,repmat(c2_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aPlot,tseg,dseg,'Color', c);
    if tracks(i).end_first_subsegment
        plot(hDFGui.aPlot,tseg(tracks(i).end_first_subsegment),dseg(tracks(i).end_first_subsegment),'LineStyle', 'none', 'Marker', 'd', 'MarkerEdgeColor',c);
    end
    if tracks(i).start_last_subsegment
        plot(hDFGui.aPlot,tseg(tracks(i).start_last_subsegment+1),dseg(tracks(i).start_last_subsegment+1),'LineStyle', 'none', 'Marker', 's', 'MarkerEdgeColor',c);
    end
    plot(hDFGui.aVelPlot,tseg,c2seg,'Color', c);
    plot(hDFGui.aIPlot,tseg,c1seg,'Color', c);
end
xy=get(hDFGui.aPlot,{'xlim','ylim'});
if xy{2}(1)<cutoff&&xy{2}(2)>cutoff
    plot(hDFGui.aPlot,[xy{1}(1) xy{1}(2)] , [cutoff cutoff], 'r-')
end
set(hDFGui.aPlot,{'xlim','ylim'},xy);
legend(hDFGui.aPlot,'off');
xlabel(hDFGui.aPlot,'time [s]');
ylabel(hDFGui.aPlot,'distance to seed [nm]'); 
xlabel(hDFGui.aVelPlot,'time [s]');
ylabel(hDFGui.aIPlot, [Options.lPlot_XVar.print ' [' Options.lPlot_XVar.str ']']); 
xlabel(hDFGui.aIPlot,'time [s]');
ylabel(hDFGui.aVelPlot, [Options.lPlot_YVar.print ' [' Options.lPlot_YVar.str ']']); 
zoom(hDFGui.aPlot, 'on');
zoom(hDFGui.aVelPlot, 'on');
zoom(hDFGui.aIPlot, 'on');
linkaxes([hDFGui.aPlot,hDFGui.aIPlot, hDFGui.aVelPlot],'x')
end
for i=2:length(Selected)
    Object = Objects(Selected(i));
    tmp=Object.TrackIds;
    track_id=[track_id; tmp(tmp>0)];
end
for i=1:length(Tracks)
    if ismember(i,track_id)
        Tracks(i).Selected=1;
    else
        Tracks(i).Selected=0;
    end
end
if isempty(tracks)
    text(0.2,0.5,'No data available for current object. You might need to press "Segment".','Parent',hDFGui.aPlot,'FontWeight','bold','FontSize',16);
end
setappdata(hDFGui.fig,'Tracks', Tracks);
setappdata(0,'hDFGui',hDFGui);