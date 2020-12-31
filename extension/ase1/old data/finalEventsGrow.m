sTracks = Tracks(~[Tracks.Shrinks]);
density = zeros(length(sTracks),1);
startendvel = zeros(length(sTracks),1);
type = zeros(length(sTracks),1);
duration = zeros(length(sTracks),1);
distance = zeros(length(sTracks),1);
g = nan(length(sTracks),1);
events = zeros(length(sTracks),1);
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
    events(i) = ~track.isPause & track.Event;
    data = track.Data(:,1:2);
    data(isnan(data(:,1)),:) = [];
    t = data(:,1);
    d = data(:,2);
    if length(d) < 2
        density(i) = nan;
        startendvel(i)=nan;
        continue
    end
    shrinkuntil = max(d)-min(d);
    distance(i) = (d(end)-d(1));
    startendvel(i) = (d(end)-d(1))/(t(end)-t(1));
    duration(i) = (t(end)-t(1));
    if shrinkuntil < 500
        density(i) = nan;
        startendvel(i) = nan;
    end
%     x = x - repmat(GFPtip,1,size(x,2));
%     for j = 1:length(d)
%         
%     end
end

boxplotP(startendvel,type,double(g),distance,[],{'Single', 'Antiparallel', 'Parallel'});

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
xticks(1:length(l));
xticklabels({'Single', 'Antiparallel', 'Parallel'});
set(gca, 'FontSize', 14);
ylabel('Rescue frequency (1/\mum)');