col = 11;
x = [];
weights = [];
type = [];

for i=1:249
    track = Tracks(i);
    if length(track.FitData) > 1
        d = fitFrame.getPlotData(track, [1:8 10]);
        d = squeeze(d(:,col,:));
        SST = track.Data2(:,2);
        rsquared = 1-d./SST;
        select = true(size(d(:,1)));% | d1(:,3) < 1;
        select(end-9:end) = 0;
        select(track.Data(:,2)<500) = 0;
        select(track.GFPTip>-500)= 0;
        select(find(select==0,1):end) = 0;
        select(isnan(track.GFPTip)) = 0;
        type = [type; ones(sum(select),1) .* isempty(strfind(track.Type,'OL'))];
        x = [x; rsquared(select,:)];
        weights = [weights; ones(sum(select),9)./sum(select)];
    end
end
unexplained = 1 - x;
i_shift = (unexplained(:,2:5)-unexplained(:,6:9))./unexplained(:,2:5);
i_exp = (unexplained(:,[2 4 6 8])-unexplained(:,[3 5 7 9]))./unexplained(:,[2 4 6 8]);
i_sig = (unexplained(:,[2 3 6 7])-unexplained(:,[4 5 8 9]))./unexplained(:,[2 3 6 7]);

a = [];
for i = 0:1
    v = i_exp(type==i,:);
a = [a; mean(v); prctile(v,25); median(v); prctile(v,75)];
end
%     imp_shift(i,:) = means(i,2:5)./means(i,6:9);
%     imp_exp(i,:) = means(i,[2 4 6 8])./means(i,[3 5 7 9]);
%     imp_sigma(i,:) = means(i,[2 3 6 7])./means(i,[4 5 8 9]);

% medians = nan(2,9);
% means = nan(2,9);
% imp_shift = nan(2,4);
% imp_exp = nan(2,4);
% imp_sigma = nan(2,4);
% imp = nan(2,3);
% for i = 1:2
%     medians(i,:) = 1-nanmedian(x(type==i-1,:));
%     means(i,:) = 1-nanmean(x(type==i-1,:));
%     imp_shift(i,:) = means(i,2:5)./means(i,6:9);
%     imp_exp(i,:) = means(i,[2 4 6 8])./means(i,[3 5 7 9]);
%     imp_sigma(i,:) = means(i,[2 3 6 7])./means(i,[4 5 8 9]);
%     imp(i,:) = [mean(imp_shift(i,:)) mean(imp_exp(i,:)) mean(imp_sigma(i,:))];
% end
% 
figure
% % box = iosr.statistics.boxPlot((1:9)-0.15, x(type==1,:), 'weights',weights(type==1,:),'medianColor','r', 'showOutliers', true, 'showMean', true)
% % hold on
% % box = iosr.statistics.boxPlot((1:9)+0.15, x(type==0,:), 'weights',weights(type==0,:),'medianColor','g', 'showOutliers', true, 'showMean', true)
% % set(box.handles.box, 'EdgeColor', 'blue')

plotvar = x;
boxsingle = iosr.statistics.boxPlot((1:size(plotvar,2))-0.15, plotvar(type==1,:), 'medianColor','r', 'showOutliers', true, 'showMean', true)
hold on
boxOL = iosr.statistics.boxPlot(1:size(plotvar,2)+0.15, plotvar(type==0,:), 'medianColor','g', 'showOutliers', true, 'showMean', true)
set(boxOL.handles.box, 'EdgeColor', 'blue')
legend([boxsingle.handles.medianLines(1) boxOL.handles.medianLines(1)], {'single MTs', 'crosslinked MTs'});
pbaspect([1 1 1]);
ylabel('R squared value');
xticklabels({'Error function', 'Error function + Gaussian'} );