function [f] = fJKplotframework(Tracks, type, plot_mode, events, Options)
%plotmodes: 0: X vs Y plot, 1: Events along X during Y, 2: filament end plot
additionalplots = 1;
if additionalplots>1
    mainfig=gcf;
    statfig=figure('Name',[get(mainfig, 'Name') '_STATS'], 'Tag','Plot');
    figure(mainfig);
end
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
[label_x, label_y, DelTracks] = SetUpMode(plot_mode, events, [Tracks.PreviousEvent]', Options);
[uniquetype, ~, idvec] = unique(type,'stable');
if plot_mode
    for i = 1:length(uniquetype)
        if ~any(events(idvec==i)) %find all types without events and remove their tracks
            DelTracks = DelTracks | idvec==i;
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
    switch ntypes
        case {1,2,3,4,5}
            f=subplot(1,ntypes,j);
            if j==1
                curent_y_label = label_y;
            end
        case 6
            f=subplot(2,3,j);
            if j==1 || j==4
                curent_y_label = label_y;
            end
        case {7, 8}
            f=subplot(2,4,j);
            if j==1 || j==5
                curent_y_label = label_y;
            end
        case {9, 10}
            f=subplot(2,5,j);
            if j==1 || j==6
                curent_y_label = label_y;
            end
        case {11, 12}
            f=subplot(2,6,j);
            if j==1 || j==7
                curent_y_label = label_y;
            end
        otherwise
            msgbox('that would be more than 12 plots! Try checking the "Only selected" checkbox');
    end
    title(uniquetype{j});
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
    switch plot_mode
        case 0
            [plot_x, plot_y, ~] = Get_Vectors(PlotTracks, events(correct_type), Options.mXReference.val, plot_mode, Options.cExclude.val);
            point_info=cell(sum(correct_type),1);
            if Options.cGroupIntoMTs.val
                [legend_items, ~, object_name_ids] = unique({PlotTracks.Name}, 'stable');
                for k=1:sum(correct_type)
                    point_info{k}=repmat(object_name_ids(k),size(PlotTracks(k).X(1+Options.cExclude.val:end-Options.cExclude.val,:)),1);
                end
                point_info=vertcat(point_info{:}); %point_info simply carries information about to which track a point belongs
            else
                legend_items = {PlotTracks.Name};
                for k=1:sum(correct_type)
                    point_info{k}=repmat(k,size(PlotTracks(k).X(1+Options.cExclude.val:end-Options.cExclude.val,:)),1);
                end
                point_info=vertcat(point_info{:});
            end
            fJKscatterboxplot(plot_x, plot_y, point_info);
            if Options.cLegend.val
                legend(legend_items, 'Interpreter', 'none', 'Location', 'best');
            else
                legend('hide');
            end
            if isfield(Options, 'FilamentEndPlot')
                if Options.FilamentEndPlot.has_err_fun_format
                    try
                        FitErf(plot_x, plot_y)
                    catch
                    end
                end
            end
        case 1
            [plot_x, plot_y, ploteventends] = Get_Vectors(PlotTracks, events(correct_type), Options.mXReference.val, plot_mode, Options.cExclude.val);
            fJKfrequencyvsXplot(plot_x, plot_y, ploteventends, {Options.lPlot_XVar.str, Options.lPlot_YVar.str});
    end
    xlabel(label_x);
    ylabel(curent_y_label);
end


function [plotx, ploty, ploteventends] = Get_Vectors(PlotTracks, plotevents, refmode, plot_mode, exclude)
%plotx and ploty are vectors with all datapoints of the group to be plotted
pr = length(PlotTracks);
cellx=cell(pr,1);
celly=cell(pr,1);
ploteventends=nan(size(plotevents));
if plot_mode
    switch refmode
        case {1,5}
        for k=1:pr
            cellx{k}=PlotTracks(k).X;
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(end);
            end
        end
        case {2, 6}
        for k=1:pr
            cellx{k}=PlotTracks(k).X-PlotTracks(k).X(1);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(end)-PlotTracks(k).X(1);
            end
        end
        case {3, 7}
        for k=1:pr
            cellx{k}=PlotTracks(k).X-PlotTracks(k).X(end);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(1)-PlotTracks(k).X(end);
            end
        end
        case 4
        for k=1:pr
            cellx{k}=PlotTracks(k).X-median(PlotTracks(k).X);
            diffy=diff(PlotTracks(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotTracks(k).X(1)-median(PlotTracks(k).X);
            end
        end
    end
else
    switch refmode
        case {1,5}
        for k=1:pr
            cellx{k}=PlotTracks(k).X(1+exclude:end-exclude);
            celly{k}=PlotTracks(k).Y(1+exclude:end-exclude);
        end
        case {2, 6}
        for k=1:pr
            cellx{k}=PlotTracks(k).X(1+exclude:end-exclude)-PlotTracks(k).X(1);
            celly{k}=PlotTracks(k).Y(1+exclude:end-exclude);
        end
        case {3, 7}
        for k=1:pr
            cellx{k}=PlotTracks(k).X(1+exclude:end-exclude)-PlotTracks(k).X(end);
            celly{k}=PlotTracks(k).Y(1+exclude:end-exclude);
        end
        case 4
        for k=1:pr
            cellx{k}=PlotTracks(k).X(1+exclude:end-exclude)-median(PlotTracks(k).X);
            celly{k}=PlotTracks(k).Y(1+exclude:end-exclude);
        end
    end
end
plotx=vertcat(cellx{:});
ploty=vertcat(celly{:});

function [labelx, labely, DelTracks] = SetUpMode(plot_mode, events, previous_event, Options)
DelTracks = false(length(events),1);
switch Options.mXReference.val
    case 1
        labelsuffixx='';
    case 2
        labelsuffixx='- start (with events only)';
        DelTracks = DelTracks | ~previous_event;
    case 3
        labelsuffixx='- end (with events only)';
        DelTracks = DelTracks | ~events';
    case 4
        labelsuffixx='- median';
    case 5
        labelsuffixx='- track velocity';
    case 6
        labelsuffixx='- start';
    case 7
        labelsuffixx='- end';
end
if plot_mode
    labelprefixy='N(events)/';
    unitprefixy='1/';
else
    labelprefixy='';
    unitprefixy='';
end
labelx=[Options.lPlot_XVar.print ' ' labelsuffixx ' [' Options.lPlot_XVar.str ']'];
labely=[labelprefixy Options.lPlot_YVar.print ' [' unitprefixy Options.lPlot_YVar.str ']'];