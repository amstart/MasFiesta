function EventPlot(group, cutoff)
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
PlotGrowing=[1 0];
for i=1:2
    [type, Tracks, event]=DF.SetType(PlotGrowing(i));
    uniquetypes=unique(type, 'stable');
    NEvents=zeros(length(uniquetypes),1);
    sumTime=zeros(length(uniquetypes),1);
    sumFrames=zeros(length(uniquetypes),1);
    subplot(2,2,2*(i-1)+1)
    hold on;
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        plot([0.5 length(uniquetypes) + 0.5] , [0 0], 'k--')
        ylabel('Catastrophe distance to seed [nm]');
    else
        plot([0.5 length(uniquetypes) + 0.5] , [cutoff cutoff], 'r-')
        ylabel('Rescue distance to seed [nm]');
    end
    for n=1:length(Tracks)
        typenum=find(strcmp(uniquetypes, type{n}));
        if ~isempty(Tracks(n).Data)
            print_str = [int2str(Tracks(n).MTIndex) '/' int2str(Tracks(n).TrackIndex)];
            if event(n)
                NEvents(typenum)=NEvents(typenum)+1;
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','red');
                plot(typenum, Tracks(n).Data(end,2), 'Color','red', 'LineStyle', 'none', 'Marker','o');
            else
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','black');
                plot(typenum, Tracks(n).Data(end,2), 'Color','black', 'LineStyle', 'none', 'Marker','o');
            end
            sumTime(typenum)=sumTime(typenum)+Tracks(n).Duration;
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    subplot(2,2,2*(i-1)+2)
    hold on
    fEvents = NEvents./sumTime;
    fError = sqrt(NEvents)./sumTime; %see https://www.bcube-dresden.de/wiki/Error_bars
    bar(fEvents,'stacked', 'r');
    h_error = errorbar(fEvents, fError, '.');
    for j=1:length(uniquetypes)
        if fEvents(j)
            text(j, fEvents(j)/2, {[num2str(fEvents(j), 2) ' per s'], ['N=' num2str(NEvents(j))], [num2str(sumTime(j)/60,'%1.1f') ' min']}, 'HorizontalAlignment', 'center', 'FontSize',16);
        else
            text(j, fEvents(j)/2, ['0 in ' num2str(sumTime(j)/60,'%1.1f') ' min'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize',16);
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        ylabel('Catastrophe frequency [1/s]');
    else
        ylabel('Rescue frequency [1/s]');
    end
    legend(h_error, 'statistical uncertainty', 'Location', 'best');
end