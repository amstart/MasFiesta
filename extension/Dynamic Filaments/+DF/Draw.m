function Draw(hDynamicFilamentsGui)
Options = getappdata(hDynamicFilamentsGui.fig,'Options');
showTrackN=get(hDynamicFilamentsGui.cshowTrackN,'Value');
cla(hDynamicFilamentsGui.aPlot, 'reset');
cla(hDynamicFilamentsGui.aVelPlot, 'reset');
cla(hDynamicFilamentsGui.aIPlot, 'reset');
tagnum=4;
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Selected=get(hDynamicFilamentsGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
eSmoothY=str2double(get(hDynamicFilamentsGui.eSmoothY, 'String'));
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    if hDynamicFilamentsGui.complicated
        cutoff=Options.eRescueCutoff.val;
        track_id=Object.SegTagAuto(:,5);
    else
        cutoff=nan;
        track_id=Object.TrackIds;
    end
    track_id=track_id(track_id>0);
    tracks=Tracks(track_id);
    [c1_vec, c2_vec] = DF.get_plot_vectors(Options, tracks, [1 2]);
    set(hDynamicFilamentsGui.fig, 'Name',['Dynamics: ' Object.Name '  (' Object.Comments ')']);
    modevents=mod(Object.SegTagAuto(Object.SegTagAuto(:,5)>0,3),1);
    if ~isempty(track_id)
    hold(hDynamicFilamentsGui.aVelPlot,'on');
    hold(hDynamicFilamentsGui.aIPlot,'on');
    hold(hDynamicFilamentsGui.aPlot,'on');
    axes(hDynamicFilamentsGui.aPlot);
    for i=1:length(tracks)
        segtrack=tracks(i).Data;
        tseg=segtrack(:,1);
        if hDynamicFilamentsGui.complicated
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
        if showTrackN
            text(double(t0),double(max(segtrack(:,2))),num2str(track_id(i)));
        end
        plot(hDynamicFilamentsGui.aPlot,tseg(pauses),dseg(pauses),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor','c');
        if floor(tracks(i).Event)==tagnum
            c='r';
            if size(dseg,1) < str2double(get(hDynamicFilamentsGui.eMinLength, 'String'))
                c=[0.7 0.7 0.7];
            end
            if modevents(i)>0.85&&dseg(end)>cutoff
                plot(hDynamicFilamentsGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            elseif modevents(i)>0.7&&dseg(end)>cutoff
                plot(hDynamicFilamentsGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            end
        else
            c='k';
            if modevents(i)>0.85
                plot(hDynamicFilamentsGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            elseif modevents(i)>0.7
                plot(hDynamicFilamentsGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            end
        end
%         plot(hDynamicFilamentsGui.aPlot,tseg,tracks(i).Velocity(end).*(tseg-t0)+d0,'b-.');
        plot(hDynamicFilamentsGui.aIPlot,tseg,repmat(c1_vec(i), 1, length(tseg)),'b-.');
        plot(hDynamicFilamentsGui.aVelPlot,tseg,repmat(c2_vec(i), 1, length(tseg)),'b-.');
        plot(hDynamicFilamentsGui.aPlot,tseg,dseg,'Color', c);
        if tracks(i).end_first_subsegment
            plot(hDynamicFilamentsGui.aPlot,tseg(tracks(i).end_first_subsegment),dseg(tracks(i).end_first_subsegment),'LineStyle', 'none', 'Marker', 'd', 'MarkerEdgeColor',c);
        end
        if tracks(i).start_last_subsegment
            plot(hDynamicFilamentsGui.aPlot,tseg(tracks(i).start_last_subsegment+1),dseg(tracks(i).start_last_subsegment+1),'LineStyle', 'none', 'Marker', 's', 'MarkerEdgeColor',c);
        end
        plot(hDynamicFilamentsGui.aVelPlot,tseg,c2seg,'Color', c);
        plot(hDynamicFilamentsGui.aIPlot,tseg,c1seg,'Color', c);
    end
    xy=get(hDynamicFilamentsGui.aPlot,{'xlim','ylim'});
    if xy{2}(1)<cutoff&&xy{2}(2)>cutoff
        plot(hDynamicFilamentsGui.aPlot,[xy{1}(1) xy{1}(2)] , [cutoff cutoff], 'r-')
    end
    set(hDynamicFilamentsGui.aPlot,{'xlim','ylim'},xy);
    legend(hDynamicFilamentsGui.aPlot,'off');
    xlabel(hDynamicFilamentsGui.aPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aPlot,'distance to seed [nm]'); 
    xlabel(hDynamicFilamentsGui.aVelPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aIPlot, [Options.lPlot_XVar.print ' [' Options.lPlot_XVar.str ']']); 
    xlabel(hDynamicFilamentsGui.aIPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aVelPlot, [Options.lPlot_YVar.print ' [' Options.lPlot_YVar.str ']']); 
    zoom(hDynamicFilamentsGui.aPlot, 'on');
    zoom(hDynamicFilamentsGui.aVelPlot, 'on');
    zoom(hDynamicFilamentsGui.aIPlot, 'on');
    linkaxes([hDynamicFilamentsGui.aPlot,hDynamicFilamentsGui.aIPlot, hDynamicFilamentsGui.aVelPlot],'x')
    end
    for i=2:length(Selected)
        Object = Objects(Selected(i));
        tmp=Object.SegTagAuto(:,5);
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
        text(0.2,0.5,'No data available for current object. You might need to press "Segment".','Parent',hDynamicFilamentsGui.aPlot,'FontWeight','bold','FontSize',16);
    end
end
setappdata(hDynamicFilamentsGui.fig,'Tracks', Tracks);
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);