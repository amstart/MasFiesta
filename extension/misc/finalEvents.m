sTracks = Tracks([Tracks.Shrinks]);
density = zeros(length(sTracks),1);
startendvel = zeros(length(sTracks),1);
type = zeros(length(sTracks),1);
duration = zeros(length(sTracks),1);
events = zeros(length(sTracks),1);
for i = 1:length(sTracks)
    track = sTracks(i);
    type(i) = isempty(strfind(track.Type,'OL'));
    events(i) = ~track.isPause & track.DistanceEventEnd > 500;
    data = track.Data(2:end,1:2);
    data(data(:,2)<500,:) = [];
    data(isnan(data(:,1)),:) = [];
    t = data(:,1);
    d = data(:,2);
    if length(d) < 2
        density(i) = nan;
        startendvel(i)=nan;
        continue
    end
    if length(track.itrace)>1
        bg = nanmean(track.itrace(1:6,:));
        bg = bg - min(bg);
        shrinkuntil = max(d)-min(d);
        shrinkuntilid = round(40 + shrinkuntil / (157/4));
        density(i) = sum(bg(40:shrinkuntilid))/(4*shrinkuntil);
    end
    startendvel(i) = (d(end)-d(1))/(t(end)-t(1));
%     x = x - repmat(GFPtip,1,size(x,2));
%     for j = 1:length(d)
%         
%     end
end
figure;scatter(density(type==1),startendvel(type==1),[],events(type==1),'d')
hold on
scatter(density(type==0),startendvel(type==0),[],events(type==0))