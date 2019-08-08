function [f] = fJKplotframework(Tracks, type, isfrequencyplot, events, Options)
%plotmodes: 0: X vs Y plot, 1: Events along X during Y, 2: filament end plot
additionalplots = 1;
if additionalplots>1
    mainfig=gcf;
    statfig=figure('Name',[get(mainfig, 'Name') '_STATS'], 'Tag','Plot');
    figure(mainfig);
end
% events(events==2) = 0; %also remove tracks with censored events
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.11], [0.2 0.08], [0.08 0.02]);
[label_x, label_y, DelTracks] = SetUpMode(isfrequencyplot, events, [Tracks.PreviousEvent]', Options);
[uniquetype, ~, idvec] = unique(type,'stable')
% if isfrequencyplot == 1
%     for i = 1:length(uniquetype)
%         if ~any(events(idvec==i)) %find all types without events and remove their tracks
%             DelTracks = DelTracks | idvec==i;
%         end
%     end
% end
% for i = 1:length(Tracks)
%     if abs(Tracks(i).X(end)-Tracks(i).X(1)) < 4000
%         DelTracks(i) = 1;
%     end
% end
if Options.lChoosePlot.val == 8
    for i = 1:length(Tracks)
        eventloc = find(Tracks(i).Data(:,1)==0);
        dist = 8;
        if isempty(eventloc)
            eventloc = 0;
        end
        if eventloc < (dist+1)
            DelTracks(i) = 1;
        else
            Tracks(i).X = Tracks(i).X(eventloc-dist:min(eventloc+dist, length(Tracks(i).X)));
            Tracks(i).Y = Tracks(i).Y(eventloc-dist:min(eventloc+dist, length(Tracks(i).Y)));
        end
    end
end
if  any(DelTracks)
    Tracks(DelTracks) = [];
    events(DelTracks) = [];
    type(DelTracks) = [];
    [uniquetype] = unique(type,'stable');
end
ntypes = length(uniquetype);
for j=1:ntypes    %Loop through all groups to be plotted, each group gets its own subplot
    if j>1 && ~isvalid(f)
        return
    end
    curent_y_label = '';
    curent_x_label = '';
    switch ntypes
        case {1,2,3,4,5}
            f=subplot(1,ntypes,j);
            if j==1
                curent_y_label = label_y;
            end
            curent_x_label = label_x;
        case 6
            f=subplot(2,3,j);
            if j==1 || j==4
                curent_y_label = label_y;
            end
            if j > 3
                curent_x_label = label_x;
            end
        case {7, 8}
            f=subplot(2,4,j);
            if j==1 || j==5
                curent_y_label = label_y;
            end
            if j > 4
                curent_x_label = label_x;
            end
        case {9, 10}
            f=subplot(2,5,j);
            if j==1 || j==6
                curent_y_label = label_y;
            end
            if j > 5
                curent_x_label = label_x;
            end
        case {11, 12}
            f=subplot(2,6,j);
            if j==1 || j==7
                curent_y_label = label_y;
            end
            if j > 6
                curent_x_label = label_x;
            end
        otherwise
            msgbox('that would be more than 12 plots! Try checking the "Only selected" checkbox');
            return
    end
    hold on;
    correct_type=cellfun(@(x) strcmp(x, uniquetype(j)),type);
    PlotTracks=Tracks(correct_type);
    if additionalplots==2
        figure(statfig);
        fqq=subplot(1,ntypes,j);
        axes(fqq);drawnow;
        qqplot(plot_x,plot_y);drawnow;
        figure(mainfig);
        axes(f);drawnow;
    end
%     set(gca,'ButtonDownFcn',@createnew_fig)
    switch isfrequencyplot
        case 0
            [plot_x, plot_y, ~] = Get_Vectors(PlotTracks, events(correct_type), Options, isfrequencyplot);
            point_info=cell(sum(correct_type),1);
%             if Options.ZOK
%                 color_mode = 1;
%                 for k=1:sum(correct_type)
%                     point_info{k}=PlotTracks(k).Z(1+Options.cExclude.val:end-Options.cExclude.val);
%                 end
%                 point_info=vertcat(point_info{:});
%             else
                color_mode = 0;
                datatiplabel = {};
                trackids = {PlotTracks.TrackIndex};
                if Options.cGroupIntoMTs.val
                    [legend_items, ~, object_name_ids] = unique({PlotTracks.Name}, 'stable');                    
                    for k=1:sum(correct_type)
                        point_info{k}=repmat(object_name_ids(k),size(PlotTracks(k).X),1);
                        datatiplabel{k} = repmat(trackids(k),length(point_info{k}),1);
                    end
                else
                    legend_items = {PlotTracks.Name};
                    for k=1:sum(correct_type)
                        point_info{k}=repmat(k,[size(PlotTracks(k).X),1]);
                        datatiplabel{k} = repmat(trackids(k),length(point_info{k}),1);
                    end
                    
                end
%             end
%             if abs(min(plot_x))/2 > max(plot_x)
%                 plot_x = - plot_x;
%             end
%             if abs(min(plot_y)) > max(plot_y)
%                 plot_y = - plot_y;
%             end
            point_info=vertcat(point_info{:}); %point_info simply carries information about to which track a point belongs
            fJKscatterboxplot(f, plot_x, plot_y, point_info, vertcat(datatiplabel{:}));
            grid
            if Options.cLegend.val
                legend(legend_items, 'Interpreter', 'none', 'Location', 'best');
            else
                legend('hide');
            end
            if isfield(Options, 'FilamentEndPlot')
                if Options.FilamentEndPlot.has_err_fun_format
                    try
                        [fitresult, gof] = FitErf(plot_x, plot_y);
                        % Plot fit with data.
                        plot( fitresult, 'k-');
                    catch
                    end
                end
            end
        case 1
            [plot_x, plot_y, ploteventends] = Get_Vectors(PlotTracks, events(correct_type), Options, isfrequencyplot);
            fJKfrequencyvsXplot(f, plot_x, plot_y, ploteventends, {Options.lPlot_XVar.str, Options.lPlot_YVar.str});
    end
    set(gca, 'FontSize', 24);
    title(uniquetype{j}, 'FontSize', 18);
    xlabel(curent_x_label);
    ylabel([curent_y_label]);
end


function [plotx, ploty, ploteventends] = Get_Vectors(PlotTracks, plotevents, Options, isfrequencyplot)
exclude = Options.cExclude.val;
refmode = [Options.mXReference.val Options.mYReference.val Options.mZReference.val];
%plotx and ploty are vectors with all datapoints of the group to be plotted
pr = length(PlotTracks);
cellx=cell(pr,1);
celly=cell(pr,1);
cellz=cell(pr,1);
ploteventends=nan(size(plotevents));
if isfrequencyplot
    switch refmode
        case {1,5}
        for k=1:pr
            try
            cellx{k}=PlotTracks(k).X;
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                if isnan(PlotTracks(k).X(end))
                    ploteventends(k)=PlotTracks(k).X(max(2,end-2));
                else
                    ploteventends(k)=PlotTracks(k).X(end);
                end
            end
            catch
                cellx{k}=[];
                celly{k}=[];
                ploteventends(k)=nan;
            end
        end
        case {2, 6}
        for k=1:pr
            cellx{k}=PlotTracks(k).X-PlotTracks(k).X(1);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(end)-PlotTracks(k).XEventStart;
            end
        end
        case {3, 7}
        for k=1:pr
            cellx{k}=PlotTracks(k).X-PlotTracks(k).X(end);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(1)-PlotTracks(k).XEventEnd;
            end
        end
        case 4
        for k=1:pr
            cellx{k}=PlotTracks(k).X-nanmedian(PlotTracks(k).X);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(1)-nanmedian(PlotTracks(k).X);
            end
        end
    end
else
    for k=1:pr
        if ~exclude
            vars = {PlotTracks(k).X PlotTracks(k).Y};
        else
            vars = {PlotTracks(k).X PlotTracks(k).Y PlotTracks(k).Z};
        end
        for j = 1:length(vars)
            var = vars{j};
            switch refmode(j)
                case {1,5}
                    cellvar=var;
                case {2}
                    cellvar=[0; diff(var)];
                case {6}
                    cellvar=var-var(1);
                case {7}
                    cellvar=var-var(end);
                case 4
                    cellvar=var-nanmedian(var);
            end
            switch j
                case 1                
                    cellx{k} = cellvar;
                case 2
                    celly{k} = cellvar;
                case 3
                    cellz{k} = cellvar;
            end
        end
        if exclude
            celly{k}=celly{k}./cellz{k};
        end
    end
end
plotx=vertcat(cellx{:});
ploty=vertcat(celly{:});

function [labelx, labely, DelTracks] = SetUpMode(plot_mode, events, previous_event, Options)
DelTracks = false(length(events),1);
for i = 1:3
    toswitch = [Options.mXReference.val Options.mYReference.val Options.mZReference.val];
    switch toswitch(i)
        case 1
            str='';
        case 2
            str='- previous frame';
            DelTracks = DelTracks | ~previous_event;
        case 3
            str='empty';
            DelTracks = DelTracks | ~events';
        case 4
            str='- median';
        case 5
            str='- track velocity';
        case 6
            str='- start';
        case 7
            str='- end';
    end
    switch i
        case 1
            labelsuffixx = str;
        case 2
            labelsuffixy = str;
        case 3
            labelsuffixz = str;
    end
end
if plot_mode == 1
    labelprefixy='N(events)/';
    unitprefixy='1/';
else
    labelprefixy='';
    unitprefixy='';
end
if strcmp(Options.lSubsegment.print, 'All') || Options.cPlotGrowingTracks.val==1
    segment = '';
else
    segment =  [' (' Options.lSubsegment.print ' only)'];
end
labelx=[Options.lPlot_XVar.print ' ' labelsuffixx ' [' Options.lPlot_XVar.str ']'];
labely=[labelprefixy Options.lPlot_YVar.print ' ' labelsuffixy ' ' segment ' [' unitprefixy Options.lPlot_YVar.str ']'];