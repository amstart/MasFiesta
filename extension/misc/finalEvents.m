sTracks = tracksall([tracksall.Shrinks]);
density = zeros(length(sTracks),1);
startendvel = zeros(length(sTracks),1);
type = zeros(length(sTracks),1);
duration = zeros(length(sTracks),1);
events = zeros(length(sTracks),1);
for i = 1:length(sTracks)
    track = sTracks(i);
    type(i) = isempty(strfind(track.Type,'OL'));
    events(i) = ~track.isPause & track.DistanceEventEnd > 500 & track.Event;
    data = track.Data(:,1:2);
    data(data(:,2)<500,:) = [];
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
        bg = nanmean(track.itrace(1:6,:));
        bg = bg - min(bg);
        shrinkuntilid = round(40 + shrinkuntil / (157/4));
        density(i) = sum(bg(40:shrinkuntilid))/(4*shrinkuntil);
    end
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
figure;scatter(density(type==1),startendvel(type==1),50,events(type==1))
xlim([0 0.18]);
ylim([0 800]);
xlabel('Ase1 density [1/nm]');
ylabel('Shrinking velocity [nm/s]');
figure;scatter(density(type==0&events==0),startendvel(type==0&events==0),50);
hold on
scatter(density(type==0&events==1),startendvel(type==0&events==1),50);
xlim([0 0.18]);
ylim([0 800]);
xlabel('Ase1 density [1/nm]');
ylabel('Shrinking velocity [nm/s]');
g = density > 0.03;
g = g - 2*type;
figure;boxplot(startendvel,g)
xticklabels({'Single MTs low Ase1 density', 'Single MTs high Ase1 density' ,'Overlapping MTs low Ase1 density','Overlapping MTs low Ase1 density'} );
ylabel('Shrinking velocity [nm/s]');

