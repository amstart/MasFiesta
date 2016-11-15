function [f] = fJKplotframework(Objects, type, exclude, refmode, isfrequencyplot, curent_y_label, units, events)
%SCATTERPLOT Summary of this function goes here
%   Detailed explanation goes here
additionalplots = 1;
if additionalplots>1
    mainfig=gcf;
    statfig=figure('Name',[get(mainfig, 'Name') '_STATS'], 'Tag','Plot');
    figure(mainfig);
end
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
[labelx, labely, DelObjects] = SetUpMode(refmode, isfrequencyplot, events, [Objects.PreviousEvent]', units, curent_y_label);
[uniquetype, ~, idvec] = unique(type,'stable');
if isfrequencyplot
    for i = 1:length(uniquetype)
        if ~any(events(idvec==i)) %find all types without events and remove their tracks
            DelObjects = DelObjects | idvec==i;
        end
    end
end
if  any(DelObjects)
    Objects(DelObjects) = [];
    events(DelObjects) = [];
    type(DelObjects) = [];
    [uniquetype] = unique(type,'stable');
end
ntypes = length(uniquetype);
for j=1:ntypes    %Loop through all groups to be plotted, each group gets its own subplot
    if j>1 && ~isvalid(f)
        return
    end
    curent_y_label = '';
    switch ntypes
        case 6
            f=subplot(2,3,j);
            if j==1 || j==4
                curent_y_label = labely;
            end
        case {7, 8}
            f=subplot(2,4,j);
            if j==1 || j==5
                curent_y_label = labely;
            end
        case {9, 10}
            f=subplot(2,5,j);
            if j==1 || j==6
                curent_y_label = labely;
            end
        otherwise
            f=subplot(1,ntypes,j);
            if j==1
                curent_y_label = labely;
            end
    end
    title(uniquetype{j});
    hold on;
    correct_type=cellfun(@(x) strcmp(x, uniquetype(j)),type);
    PlotObjects=Objects(correct_type);
    [plotx, ploty, ploteventends] = CalculateReference(PlotObjects, events(correct_type), refmode, isfrequencyplot, exclude);
    %plotx and ploty are vectors with all datapoints of the group to be plotted
    %which track a point belongs to (first column) and whether it is selected (second column)
    if additionalplots==2
        figure(statfig);
        fqq=subplot(1,ntypes,j);
        axes(fqq);drawnow;
        qqplot(plotx,ploty);drawnow;
        figure(mainfig);
        axes(f);drawnow;
    end
    if isfrequencyplot
        fJKfrequencyvsXplot(plotx, ploty, ploteventends, units);
    else
        point_info=cell(sum(correct_type),1);
        for k=1:sum(correct_type)
            point_info{k}=repmat(k,size(PlotObjects(k).X(1+exclude:end-exclude,:)),1);
        end
        point_info=vertcat(point_info{:}); %plotN is a matrix which is used to identify:
        fJKscatterboxplot(plotx, ploty, point_info);
        legend({PlotObjects.Name}, 'Interpreter', 'none');
    end
    xlabel(labelx);
    ylabel(curent_y_label);
end


function [plotx, ploty, ploteventends] = CalculateReference(PlotObjects, plotevents, refmode, isfrequencyplot, exclude)
pr = length(PlotObjects);
cellx=cell(pr,1);
celly=cell(pr,1);
ploteventends=nan(size(plotevents));
if isfrequencyplot
    switch refmode
        case {1,5}
        for k=1:pr
            cellx{k}=PlotObjects(k).X;
            diffy=diff(PlotObjects(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotObjects(k).X(end);
            end
        end
        case {2, 6}
        for k=1:pr
            cellx{k}=PlotObjects(k).X-PlotObjects(k).X(1);
            diffy=diff(PlotObjects(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotObjects(k).X(end)-PlotObjects(k).X(1);
            end
        end
        case {3, 7}
        for k=1:pr
            cellx{k}=PlotObjects(k).X-PlotObjects(k).X(end);
            diffy=diff(PlotObjects(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotObjects(k).X(1)-PlotObjects(k).X(end);
            end
        end
        case 4
        for k=1:pr
            cellx{k}=PlotObjects(k).X-median(PlotObjects(k).X);
            diffy=diff(PlotObjects(k).Y);
            celly{k}=[diffy(1)/2; (diffy(1:end-1)+diffy(2:end))/2; diffy(end)/2];
            if plotevents(k)
                ploteventends(k)=PlotObjects(k).X(1)-median(PlotObjects(k).X);
            end
        end
    end
else
    switch refmode
        case {1,5}
        for k=1:pr
            cellx{k}=PlotObjects(k).X(1+exclude:end-exclude);
            celly{k}=PlotObjects(k).Y(1+exclude:end-exclude);
        end
        case {2, 6}
        for k=1:pr
            cellx{k}=PlotObjects(k).X(1+exclude:end-exclude)-PlotObjects(k).X(1);
            celly{k}=PlotObjects(k).Y(1+exclude:end-exclude);
        end
        case {3, 7}
        for k=1:pr
            cellx{k}=PlotObjects(k).X(1+exclude:end-exclude)-PlotObjects(k).X(end);
            celly{k}=PlotObjects(k).Y(1+exclude:end-exclude);
        end
        case 4
        for k=1:pr
            cellx{k}=PlotObjects(k).X(1+exclude:end-exclude)-median(PlotObjects(k).X);
            celly{k}=PlotObjects(k).Y(1+exclude:end-exclude);
        end
    end
end
plotx=vertcat(cellx{:});
ploty=vertcat(celly{:});

function [labelx, labely, DelObjects] = SetUpMode(refmode, isfrequencyplot, events, previous_event, units, labels)
DelObjects = false(length(events),1);
switch refmode
    case 1
        labelsuffixx='';
    case 2
        labelsuffixx='- start (with events only)';
        DelObjects = DelObjects | ~previous_event;
    case 3
        labelsuffixx='- end (with events only)';
        DelObjects = DelObjects | ~events';
    case 4
        labelsuffixx='- median';
    case 5
        labelsuffixx='- track velocity';
    case 6
        labelsuffixx='- start';
    case 7
        labelsuffixx='- end';
end
if isfrequencyplot
    labelprefixy='N(events)/';
    unitprefixy='1/';
else
    labelprefixy='';
    unitprefixy='';
end
labelx=[labels{1} ' ' labelsuffixx ' [' units{1} ']'];
labely=[labelprefixy labels{2} ' [' unitprefixy units{2} ']'];