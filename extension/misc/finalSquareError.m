col = 10;
x = [];
weights = [];
type = [];

for i=1:length(Tracks)
    track = Tracks(i);
    if length(track.FitData) > 1
        d = fitFrame.getPlotData(track, 1:9);
        d = squeeze(d(:,col,:));
        SST = track.Data2(:,2);
        rsquared = 1-d./SST;
%         n = repmat(diff(track.minima,[],2)./4,1,9);
%         p = repmat([2 3 4 4 5 4 5 5 6],length(SST),1);
%         adjrsquared = 1 - (1-rsquared) .* (n - 1)./(n-p-1);
%         k = p + 2;
%         AIC = n .* log(d./n) + 2 * k + 2*k.*(k + 1) ./ (n - k - 1);
        select = true(size(d(:,1)));% | d1(:,3) < 1;
        select(end-9:end) = 0;
        select(track.Data(:,2)<500) = 0;
        select(find(select==0,1):end) = 0;
        select(isnan(d(:,7))) = 0;
        type = [type; ones(sum(select),1) .* isempty(strfind(track.Type,'OL'))];
        x = [x; d(select,:)];
        weights = [weights; ones(sum(select),9)./sum(select)];
    end
end
medians = nan(2,9);
means = nan(2,9);
imp_shift = nan(2,4);
imp_exp = nan(2,4);
imp_sigma = nan(2,4);
imp = nan(2,3);
for i = 1:2
    medians(i,:) = nanmedian(x(type==i-1,:));
    means(i,:) = nanmean(x(type==i-1,:));
    imp_shift(i,:) = means(i,6:9)-means(i,2:5);
    imp_exp(i,:) = means(i,[3 5 7 9])-means(i,[2 4 6 8]);
    imp_sigma(i,:) = means(i,[4 5 8 9])-means(i,[2 3 6 7]);
    imp(i,:) = [mean(imp_shift_med(i,:)) mean(imp_exp_med(i,:)) mean(imp_sigma_med(i,:))];
end

figure
% box = iosr.statistics.boxPlot((1:9)-0.15, x(type==1,:), 'weights',weights(type==1,:),'medianColor','r', 'showOutliers', true, 'showMean', true)
% hold on
% box = iosr.statistics.boxPlot((1:9)+0.15, x(type==0,:), 'weights',weights(type==0,:),'medianColor','g', 'showOutliers', true, 'showMean', true)
% set(box.handles.box, 'EdgeColor', 'blue')

box = iosr.statistics.boxPlot((1:9)-0.15, x(type==1,:), 'medianColor','r', 'showOutliers', true, 'showMean', true)
hold on
box = iosr.statistics.boxPlot((1:9)+0.15, x(type==0,:), 'medianColor','g', 'showOutliers', true, 'showMean', true)
set(box.handles.box, 'EdgeColor', 'blue')
