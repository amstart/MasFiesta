col = 11;
x = [];
weights = [];
type = [];
for i=1:length(Tracks)
    if length(Tracks(i).FitData) > 1
        d = fitFrame.getPlotData(Tracks(i), 1:9);
        select = true(size(d(:,1)));% | d1(:,3) < 1;
        select(end-9:end) = 0;
        select(Tracks(i).Data(:,2)<500) = 0;
        select(find(select==0,1):end) = 0;
        select(isnan(d(:,7))) = 0;
        type = [type; ones(sum(select),1) .* isempty(strfind(Tracks(i).Type,'OL'))];
        x = [x; squeeze(d(select,col,:))];
        weights = [weights; ones(sum(select),9)./sum(select)];
        
        bg = track.itrace(1:6,:);
        x = double((((0:length(bg)-1)-40)*157/4) - track.Data(2,2));

        for iframe = find(select)
            itrace = track.itrace(iframe+4,:);
            yn = itrace-bg;   
            GFPTip = track.GFPTip(iframe);
            [~,idGFPTip] = min(abs(x-GFPTip));
            ym = [itrace(1:idGFPTip) yn(idGFPTip+1:end)+itrace(idGFPTip+1)-yn(idGFPTip+1)];
        end
    end
end
figure
box = iosr.statistics.boxPlot((1:9)-0.15, x(type==1,:), 'weights',weights(type==1,:),'medianColor','r', 'showOutliers', false, 'showMean', true)
hold on
box = iosr.statistics.boxPlot((1:9)+0.15, x(type==0,:), 'weights',weights(type==0,:),'medianColor','g', 'showOutliers', false, 'showMean', true)
set(box.handles.box, 'EdgeColor', 'blue')
