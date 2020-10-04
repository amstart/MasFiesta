figure
hold on
all = [];
for i=1:length(Tracks)
    track = Tracks(i);
    if ~(length(track.FitData) > 1) || isempty(strfind(track.Type,'OL'))
        continue
    end
    GFPtip = track.GFPTip;
    select = GFPtip < -500;
    select(isnan(GFPtip)) = 1;
    select(end-9:end) = 0;
    select(find(select==0,1):end) = 0;
    select(isnan(GFPtip)) = 0;
    select(~isnan(track.tags(5:end))) = 0;
    bg = nanmean(track.itrace(1:5,:));  
    itrace = track.itrace(5:end,:);
    itrace = itrace(select,:);
    GFPtip = GFPtip(select);


    for j = 1:length(GFPtip)
        x = double((((0:length(itrace(1,:))-1)-28)*157/4) - track.Data(2,2)) - GFPtip(j);
        yn = itrace(j,:)-bg;
        yn = yn / (4*157);
        [~,idx] = min(abs(x));
        peak = yn(idx);
%         yn = yn./max(yn);
        yn = yn(x>-1000 & x<1500);
        x = x(x>-1000 & x<1500);
        if peak > 0.005
            all = [all;yn(1:62)];
        end
        lh = plot(x,yn,'k');
        lh.Color = [lh.Color 0.1];
    end

end
% rightHW = nan(size(all,1),1); %THIS IS THE SAME AS THE HW OF THE MEDIAN LINE
% for i = 1:length(rightHW)
%     l = all(i,:)-all(i,end);
%     l = l./l(25);
%     rightHW(i) = x(find(l(25:end)<0.5,1)+24);
% end
% vline(median(rightHW),'g');
mline = median(all);
h = plot(x(1:62),mline,'r');
mline = mline - mline(end);
mline = mline./max(mline);
vline(x(find(mline(25:end)<0.5,1)+24));
legend(h,'Median (of where peak density > 0.005');
title('Single MTs');
set(gca, 'FontSize', 14)
pbaspect([1 1 1]);
xlabel('Distance from MT tip [nm]');
ylabel('Ase1 density - steady-state [Ase1/nm]')