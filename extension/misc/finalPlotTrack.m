trackN = 17;
track = Tracks(trackN);

tipx = - track.Data(1:end-10,2);
bg = mean(track.itrace(1:5,:));
x = -double((((0:length(bg)-1)-28)*157/4) + tipx(2));

bg = bg(x>-1000);
itracemat = track.itrace(5:end-10, x>-1000);
x = x(x>-1000);

figure
title(num2str(trackN));
bgline = plot(x,bg, 'k--');
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
    nofitline = plot(x(1:minima(1)),itrace(1:minima(1)), 'Color', colors(iframe,:), 'LineStyle', ':');
    fitline =  plot(x(minima(1):minima(2)),[itrace(minima(1):idGFPTip) yn(idGFPTip+1:minima(2))+itrace(idGFPTip+1)-yn(idGFPTip+1)], ...
        'Color', colors(iframe,:));
end
colormap('cool');
time = track.Data2(find(select, 1, 'last'),1) - track.Data2(1,1);
c = colorbar('Ticks',[0,1], 'TickLabels',{'0',num2str(time,2)});
c.Label.String = 'time after catastrophe [s]';
ylabel('Ase1 count [1]')
xlabel('Distance from seed [nm]')
pbaspect([2 1 1]);
legend([bgline fitline nofitline], {'Ase1 profile before catastrophe', 'Ase1 profile at MT tip (used for fitting)', 'Ase1 profile beyond MT tip (not used for fitting)'});
xlim([-1000 0])