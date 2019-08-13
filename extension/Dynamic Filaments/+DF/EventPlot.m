function EventPlot(group, cutoff)
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
PlotGrowing=[1 0];
for i=1:2
    [type, Tracks, event, orderid]=DF.SetType(PlotGrowing(i), 'file');
    [uniquetypes, ~, typeid]=unique(type, 'stable');
    NEvents=zeros(length(uniquetypes),1);
    sumTime=zeros(length(uniquetypes),1);
    [~, uniqueorder, uidid] = unique(orderid, 'stable');
    NEventsO=zeros(length(uniqueorder),1);
    sumTimeO=zeros(length(uniqueorder),1);
    subplot(2,2,2*(i-1)+1)
    set(gca,'ButtonDownFcn',@createnew_fig)
    hold on;
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        plot([0.5 length(uniquetypes) + 0.5] , [0 0], 'k--')
        ylabel('Distance to seed [nm]');
    else
        plot([0.5 length(uniquetypes) + 0.5] , [cutoff cutoff], 'r-')
        ylabel('Distance to seed [nm]');
    end
    for n=1:length(Tracks)
        typenum=find(strcmp(uniquetypes, type{n}));
        if ~isempty(Tracks(n).Data)
            print_str = [int2str(Tracks(n).MTIndex) '/' int2str(Tracks(n).TrackIndex)];
            if event(n)
                NEvents(typenum)=NEvents(typenum)+1;
                NEventsO(uidid(n))=NEventsO(uidid(n))+1;
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','red');
                plot(typenum, Tracks(n).Data(end,2), 'Color','red', 'LineStyle', 'none', 'Marker','o');
            else
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','black');
                plot(typenum, Tracks(n).Data(end,2), 'Color','black', 'LineStyle', 'none', 'Marker','o');
            end
            sumTime(typenum)=sumTime(typenum)+Tracks(n).Duration/60;
            sumTimeO(uidid(n))=sumTimeO(uidid(n))+Tracks(n).Duration/60;
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    subplot(2,2,2*(i-1)+2)
    set(gca,'ButtonDownFcn',@createnew_fig)
    hold on
    if 0
        frequencies = accumarray(typeid(uniqueorder), NEventsO./sumTimeO, [], @(x) {x});
        fEvents = accumarray(typeid(uniqueorder), NEventsO./sumTimeO, [], @median);
        bar(fEvents,'stacked', 'r');
        flow = accumarray(typeid(uniqueorder), NEventsO./sumTimeO, [], @min);
        fhigh = accumarray(typeid(uniqueorder), NEventsO./sumTimeO, [], @max);
        h_error = errorbar(1:length(fEvents), fEvents, fEvents-flow, fhigh-fEvents, '.');
    else       
        fEvents = NEvents./sumTime;
        bar(fEvents,'stacked', 'r');
        fError = sqrt(NEvents)./sumTime; %see https://www.bcube-dresden.de/wiki/Error_bars
        h_error = errorbar(1:length(fEvents), fEvents, fError, '.');
    end
    %text on bars
    MTnum = accumarray(typeid, [Tracks.MTIndex], [], @uniquecount);
    movienum = accumarray(typeid(uniqueorder),1);
    for j=1:length(uniquetypes)
        if fEvents(j)
            text(j, fEvents(j)/2, {[num2str(NEvents(j)) ' events'], [num2str(sumTime(j),'%1.1f') ' min'],[num2str(MTnum(j)) 'MTs'], [num2str(movienum(j)) ' experiments']}, 'HorizontalAlignment', 'center', 'FontSize',16);
        else
            text(j, fEvents(j)/2, {['0 in ' num2str(sumTime(j),'%1.1f') ' min'], [num2str(MTnum(j)) ' MTs'], [num2str(movienum(j)) ' experiments']}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize',16);
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        ylabel('Catastrophe frequency [1/min]');
    else
        ylabel('Rescue frequency [1/min]');
    end
    legend(h_error, '$\frac{\sqrt{N}}{\sum{t}}$', 'Location', 'best', 'Interpreter', 'LaTex', 'FontSize', 20);
end



function out = uniquecount(in)
u = unique(in);
out = length(u);
