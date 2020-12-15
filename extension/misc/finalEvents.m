sTracks = Tracks([Tracks.Shrinks]);
density = zeros(length(sTracks),1);
startendvel = zeros(length(sTracks),1);
type = zeros(length(sTracks),1);
duration = zeros(length(sTracks),1);
distance = zeros(length(sTracks),1);
events = zeros(length(sTracks),1);
for i = 1:length(sTracks)
    track = sTracks(i);
    if ~isempty(strfind(track.Type,'Single'))
        type(i) = 0;
    elseif ~isempty(strfind(track.Type,'OLP'))
        type(i) = 2;
    else
        type(i) = 1;
    end
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
g = g - 10*type;
idx = unique(g);
matrix = [];
dmatrix = [];
distmatrix = [];
for i = idx'
    matrix = [matrix,[startendvel(g==i); nan(max(0,size(matrix,1)-sum(g==i)),1)]];
    dmatrix = [dmatrix,[duration(g==i); nan(max(0,size(matrix,1)-sum(g==i)),1)]];
    distmatrix = [distmatrix,[distance(g==i); nan(max(0,size(matrix,1)-sum(g==i)),1)]];
end
figure;iosr.statistics.boxPlot(matrix, 'medianColor','r', 'showScatter', true, 'sampleFontSize', 13, 'sampleSize',true)
hold on
row1 = {'Single' 'Single' 'Antiparallel' 'Antiparallel'};
row2 = {'-Ase1' '~0.075 Ase1/nm (4uM)' '~0 Ase1/nm' '~0.075 Ase1/nm (1uM)'};
labelArray = [row1; row2];
clear tickLabels;
tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
ax = gca(); 
ax.XTickLabel = tickLabels; 
ylabel('Shrinking velocity [nm/s]');
[p,tbl,stats]  = anova1(startendvel,g,'off');
table = multcompare(stats,'Display','off');
sigstar({[1 3], [2,4]}, [0.0122, nan]);
set(gca, 'FontSize', 13);
pbaspect([1 1 1]);
figure
bar([0; 0; 0; 1000*sum(events)]'./nansum(distmatrix))
ax = gca(); 
ax.XTickLabel = tickLabels; 
text(1:4, ones(1,4).* 0.05, strsplit(num2str(nansum(distmatrix)./1000,3)));
set(gca, 'FontSize', 14); 
ylabel('Rescue frequency [1/um]');