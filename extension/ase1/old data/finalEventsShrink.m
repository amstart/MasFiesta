sTracks = Tracks([Tracks.Shrinks]);
density = zeros(length(sTracks),1);
startendvel = zeros(length(sTracks),1);
type = zeros(length(sTracks),1);
duration = zeros(length(sTracks),1);
distance = zeros(length(sTracks),1);
events = zeros(length(sTracks),1);
g = nan(length(sTracks),1);
[~,~,mov] = unique({sTracks.File});
for i = 1:length(sTracks)
    track = sTracks(i);
    if ~isempty(strfind(track.Type,'Single'))
        type(i) = 1;
    elseif ~isempty(strfind(track.Type,'OLP'))
        type(i) = 3;
    else
        type(i) = 2;
    end
    g(i) = isempty(strfind(track.Type,'-'));
    events(i) = ~track.isPause & track.DistanceEventEnd > 500 & track.Event;
    data = track.Data(:,1:2);
    track.tags(data(:,2)<500,:) = 6;
    data(find(track.tags(5:end)==6,1):end,:) = [];
    data(isnan(data(:,1)),:) = [];
    t = data(:,1);
    d = data(:,2);
    if length(d) < 2
        density(i) = nan;
        startendvel(i)=nan;
        continue
    end
    shrinkuntil = max(d)-min(d);
    if length(track.itrace)>1
        bg = nanmean(track.itrace(1:5,:));
        bg = bg - min(bg);
        shrinkuntilid = round(29 + shrinkuntil / (157/4));
        density(i) = sum(bg(29:shrinkuntilid))/(4*shrinkuntil);
    end
    distance(i) = -(d(end)-d(1));
    startendvel(i) = -(d(end)-d(1))/(t(end)-t(1));
    duration(i) = t(end)-t(1);
    if shrinkuntil < 500
        density(i) = nan;
        startendvel(i) = nan;
    end
%     x = x - repmat(GFPtip,1,size(x,2));
%     for j = 1:length(d)
%         
%     end
end
% figure;scatter(density(type==1),startendvel(type==1),50,events(type==1))
% xlim([0 0.18]);
% ylim([0 800]);
% xlabel('Ase1 density [1/nm]');
% ylabel('Shrinking velocity [nm/s]');
% figure;scatter(density(type==0&events==0),startendvel(type==0&events==0),50);
% hold on
% scatter(density(type==0&events==1),startendvel(type==0&events==1),50);
% % xlim([0 0.18]);
% ylim([0 800]);
% xlabel('Ase1 density [1/nm]');
% ylabel('Shrinking velocity [nm/s]');
% g = density > 0.005;
% g = g + type;
boxplotP(startendvel,type,double(g),distance,[],{'Single', 'Antiparallel', 'Parallel'});
% hold on
% row1 = {'Single' 'Single' 'Antiparallel' 'Antiparallel'};
% row2 = {'-Ase1' '~0.075 Ase1/nm (4uM)' '~0 Ase1/nm' '~0.075 Ase1/nm (1uM)'};
% labelArray = [row1; row2];
% clear tickLabels;
% tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
% ax = gca(); 
% ax.XTickLabel = tickLabels; 
% ylabel('Shrinking velocity [nm/s]');
% [p,tbl,stats]  = anova1(startendvel,g,'off');
% table = multcompare(stats,'Display','off');
% sigstar({[1 3], [2,4]}, [0.0122, nan]);
% set(gca, 'FontSize', 13);
% pbaspect([1 1 1]);
figure
hold on
gr = (type-1)*2 + g +1;
dist = accumarray(gr,distance)/1000;
freq = accumarray(gr,events)./dist;
a = [freq(1:2) freq(3:4) freq(5:6)]';
bar(1:3, a);
freqt = nan(6,7);
for i = 1:length(dist)
    [check,~,id] = unique(mov(gr==i));
    eventst = accumarray(id,events(gr==i));
    distancet = accumarray(id,distance(gr==i));
    freqt(i,1:length(eventst)) = 1000*eventst./distancet;
end
low = freq - min(freqt, [], 2);
high = max(freqt, [], 2) - freq;
ngroups = 3;
nbars = 2;
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:2
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, freq([0 2 4]+i), low([0 2 4]+i), high([0 2 4]+i), 'k', 'LineStyle', 'None');
    text(x - groupwidth/6, freq([0 2 4]+i)./2, num2str(dist([0 2 4]+i),3));
end
xticks(1:3);
xticklabels({'Single', 'Antiparallel', 'Parallel'});
set(gca, 'FontSize', 14);
ylabel('Rescue frequency (1/\mum)');