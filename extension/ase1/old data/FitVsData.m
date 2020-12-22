figure
hold on
all = [];

for i=1:length(Tracks)
    track = Tracks(i);
    if ~(length(track.FitData) > 1) || ~strcmp(track.Type,'OL +Ase1') %{'Single/OL +Ase1'}
        continue
    end
    GFPtip = track.GFPTip;
    select = GFPtip < -500;
    select(isnan(GFPtip)) = 1;
    select(end-9:end) = 0;
    select(find(select==0,1):end) = 0;
    select(isnan(GFPtip)) = 0;
    select(~isnan(track.tags(5:end))) = 0;
    select(find(track.tags(5:end)==6,1):end) = 0;
    
    select(1:2) = 0;
    
    bg = nanmean(track.itrace(1:5,:));  
    itrace = track.itracetub(5:end,:);
    itrace = itrace(select,:);
    GFPtip = GFPtip(select);
    fitdata = fitFrame.getPlotData(track,9);
    fitdata = double(fitdata(select,:));

    for j = 1:length(GFPtip)
        to_add = nan(1,2000);
        fdata = fitdata(j,3:end);
        
        x = double((((0:length(itrace(1,:))-1)-28)*157/4) - track.Data(2,2)) - GFPtip(j);
        [~,idGFPTip] = min(abs(x));
%         yn = itrace(j,:)-bg;
%         ym = [itrace(j,1:idGFPTip) yn(idGFPTip+1:end)+itrace(j,idGFPTip+1)-yn(idGFPTip+1)];
        yn = itrace(j,:)-min(itrace(j,1:idGFPTip));
        ym = yn/max(yn(idGFPTip-10:idGFPTip+10));
        ymf = ym;%./max(ym(idGFPTip-15:idGFPTip+15));

%         yf = fitFrame.fun1(x+fdata(5),fdata);
%         ymf = ym - yf;
%         ymf = ymf ./ 157;

%         ymf = ymf(x<-1000 & x>1500);
        to_add(501-idGFPTip:500-idGFPTip+length(ymf)) = ymf;
        all = [all;to_add];
    end

end
c = linspecer(7,'sequential');
tmp = c(1,:);
c(1,:) = c(4,:);
c(4,:) = tmp;
cstep = abs(max(all(:))-min(all(:)))./7;
call = all - min(all(:))+1e-5;
xnew = (-499:1500)*157/4;
for j = 1:size(all,1)
        lh = plot(xnew,all(j,:),'Color',c(ceil(call(j,490)/cstep),:));
        lh.Color = [lh.Color 0.5];
end
% rightHW = nan(size(all,1),1); %THIS IS THE SAME AS THE HW OF THE MEDIAN LINE
% for i = 1:length(rightHW)
%     l = all(i,:)-all(i,end);
%     l = l./l(25);
%     rightHW(i) = x(find(l(25:end)<0.5,1)+24);
% end
% vline(median(rightHW),'g');
mline = nanmedian(all);
h = plot(xnew,mline,'r');

legend(h,'Median');
set(gca, 'FontSize', 14)
xlim([-1500 1500]);
pbaspect([1 1 1]);
xlabel('Distance from MT tip [nm]');
ylabel('Ase1 density - fit [molecules/nm]');