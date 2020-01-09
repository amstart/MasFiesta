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
    drawFil(hDFGui, Object, Tracks, Selected, Options, Objects);
end

function drawFil(hDFGui, Object, Tracks, Selected, Options, Objects)
cutoff=Options.eRescueCutoff.val;
track_id=Object(1).TrackIds;

track_id=track_id(track_id>0);
tracks=Tracks(track_id);
try
[c1_vec, c2_vec] = DF.get_plot_vectors(Options, tracks, [1 2]);
catch
    return
end
set(hDFGui.fig, 'Name',['Dynamics: ' Object.Name '  (' Object.Comments ')']);
% modevents=mod(Object.SegTagAuto(Object.TrackIds>0,3),1);
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
    dseg=segtrack(:,2);
    c2seg=segtrack(:, Options.lPlot_YVar.val, Options.lPlot_YVardim.val);
    c1seg=segtrack(:, Options.lPlot_XVar.val, Options.lPlot_XVardim.val);
    d0=round(nanmean(segtrack(:,2)));
    t0=segtrack(round(size(segtrack,1)/2),1);
    if get(hDFGui.cshowTrackN,'Value')
        text(double(t0),double(max(segtrack(:,2))),num2str(track_id(i)));
    end
    plot(hDFGui.aPlot,tseg(pauses),dseg(pauses),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor','c');
    if tracks(i).Shrinks
        c='r';
        if size(dseg,1) < str2double(get(hDFGui.eMinLength, 'String'))
            c=[0.7 0.7 0.7];
        end
    else
        c='k';
    end
    if tracks(i).isPause
        c='b';
        plot(hDFGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor',c);
    end
    if ~tracks(i).CensoredEvent && tracks(i).Event && (dseg(end) > cutoff || ~tracks(i).Shrinks)
        plot(hDFGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
    elseif tracks(i).CensoredEvent && (dseg(end) > cutoff || ~tracks(i).Shrinks)
        plot(hDFGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
    end
%         plot(hDFGui.aPlot,tseg,tracks(i).Velocity(end).*(tseg-t0)+d0,'b-.');
    plot(hDFGui.aIPlot,tseg,repmat(c1_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aVelPlot,tseg,repmat(c2_vec(i), 1, length(tseg)),'b-.');
    plot(hDFGui.aPlot,tseg,dseg,'Color', c);
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
    track_id=[track_id tmp(tmp>0)];
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