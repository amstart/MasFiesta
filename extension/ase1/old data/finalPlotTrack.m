trackN = 88;
track = Tracks(trackN);

tipx = - track.Data(1:end-10,2);

alltrace = track.itrace;
% alltrace = alltrace./max(max(alltrace));
bg = nanmean(alltrace(1:5,:));
x = -double((((0:length(bg)-1)-28)*157/4) + tipx(2));

itracemat = alltrace(5:end-10, :);
% iperm = 1200;
% for i = 1:length(signals)
%     signal = signals{i};
% itracemat = double(signal(5:end,:))./iperm;
% bg = mean(signal(1:5,:))./iperm;
% x = 0:157/4:(size(itracemat,2)*157/4)-1;

figure
% title(num2str(i));
% title(num2str(trackN));
% bgline = plot(x,bg, 'k--');
hold on

select = ones(size(itracemat,1),1);%track.GFPTip<-500 | isnan(track.GFPTip);
% select(end-9:end) = 0;
% select(tipx>-500) = 0;


colors = cool(sum(select));
for iframe = find(select)'
    itrace = itracemat(iframe,:)./ 157;
%     if ~isnan(track.tags(iframe+4)) || isnan(track.GFPTip(iframe))
%         continue
%     end
%     yn = itrace - bg;
%     GFPTip = track.GFPTip(iframe);
%     minima = track.minima(iframe,:);
%     [~,idGFPTip] = min(abs(-x-GFPTip));
%     nofitline = plot(x(1:minima(1)),itrace(1:minima(1)), 'Color', colors(iframe,:), 'LineStyle', ':');
    fitline =  plot(x,itrace, ...
        'Color', colors(iframe,:));
%     nofitline = plot(x(1:minima(1)),itrace(1:minima(1)), 'Color', colors(iframe,:), 'LineStyle', ':');
%     fitline =  plot(x(minima(1):minima(2)),[itrace(minima(1):idGFPTip) yn(idGFPTip+1:minima(2))+itrace(idGFPTip+1)-yn(idGFPTip+1)], ...
%         'Color', colors(iframe,:));
end
colormap('cool');
time = track.Data2(find(select, 1, 'last'),1) - track.Data2(1,1);
c = colorbar('Ticks',[0,1], 'TickLabels',{'0',num2str(time,2)});
c.Label.String = 'time after catastrophe [s]';
ylabel('Ase1 density [molecules/nm]')
xlabel('Distance from seed [nm]')
pbaspect([2 1 1]);
set(gca, 'FontSize', 14)
% legend([bgline fitline nofitline], {'Ase1 profile before catastrophe', 'Ase1 profile at MT tip (used for fitting)', 'Ase1 profile beyond MT tip (not used for fitting)'});
% xlim([-1000 0])
% end