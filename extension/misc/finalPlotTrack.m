track = Tracks(6);

tipx = - track.Data(1:end-10,2);
bg = mean(track.itrace(1:5,:));
x = -double((((0:length(bg)-1)-28)*157/4) + tipx(2));

bg = bg(x>-1000);
itracemat = track.itrace(5:end-10, x>-1000);
x = x(x>-1000);

figure
plot(x,bg, 'k--');
hold on

select = track.GFPTip<-500 | isnan(track.GFPTip);
select(end-9:end) = 0;
select(tipx>-500) = 0;


colors = cool(sum(select));
for iframe = find(select)'
    itrace = itracemat(iframe,:);
    if ~isnan(track.tags(iframe+4)) || isnan(track.GFPTip(iframe))
        continue
    end
    yn = itrace - bg;
    GFPTip = track.GFPTip(iframe);
    minima = track.minima(iframe,:);
    [~,idGFPTip] = min(abs(-x-GFPTip));
    plot(x(1:minima(1)),itrace(1:minima(1)), ...
    'Color', colors(iframe,:), 'LineStyle', ':');
    plot(x(minima(1):minima(2)),[itrace(minima(1):idGFPTip) yn(idGFPTip+1:minima(2))+itrace(idGFPTip+1)-yn(idGFPTip+1)], ...
        'Color', colors(iframe,:));
end
colormap('cool');
time = track.Data2(find(select, 1, 'last'),1) - track.Data2(1,1);
c = colorbar('Ticks',[0,1], 'TickLabels',{'0',num2str(time,2)});
c.Label.String = 'time after catastrophe [s]';