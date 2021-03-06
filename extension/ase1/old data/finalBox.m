col = 3;
x = [];
weights = [];
type = [];

for i=1:249
    track = Tracks(i);
    if length(track.FitData) > 1
        d = squeeze(fitFrame.getPlotData(track, 12));
        d2 = squeeze(fitFrame.getPlotData(track, 12));
        select = true(size(d(:,3)));% | amplitude < 1;
        select(end-9:end) = 0;
        select(track.Data(:,2)<500) = 0;
        select(track.GFPTip>-500)= 0;
        select(find(select==0,1):end) = 0;
        select = select & ~isnan(d(:,3));
        

        d2 = d2(select,:);
        
        d = d(select,:);
        
        tip1 = d(:,7);
        tip2 = d2(:,7);
        
        t = d(:,1);
        amplitude = d(:,3);
        sigma = d(:,4);
        ase1ingauss = d(:,12);
        ase1passed = d(:,15);
        steady_d = track.SteadyStateDensity;
        norm_d = d(:,19);
        
        a = ase1ingauss;%(tip2+[tip2(2:end); nan])/2-tip1;
%         a =  d(:,end-1)./157;%[nan; diff(ase1ingauss)]./ase1passed;
%         aing = squeeze(d(:,12));

%         
        
%         select = select & amplitude > 1;

        
        if isempty(a)
            continue
        end
%         type = [type; isempty(strfind(track.Type,'OL'))];
%         p = polyfit(t,a,1);
%         x = [x; a(find(~isnan(a), 1, 'last'))/a(1)];
%         x = [x; p(1)/a(1)];
%         x = [x; p(1)];
        
        if ~isempty(strfind(track.Type,'Single'))
            tmp = 0;
        elseif ~isempty(strfind(track.Type,'OLP'))
            tmp = 2;
        else
            tmp = 1;
        end
        type = [type; tmp];
        x = [x; nanmean(a)/nanmean(steady_d)];
%         type = [type; ones(sum(select),1) .* tmp];
%         x = [x; a];
        weights = [weights; ones(sum(select),9)./sum(select)];
    end
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
boxsingle = boxPlot(plotvar, type, [], 'medianColor','r', 'showOutliers', true, 'showScatter', true, 'sampleSize',true)
hold on
pbaspect([1 1 1]);
xticklabels({'Single MTs [4nM]', 'Antiparallel [1nM]', 'Parallel [1nM]'} );
set(gca, 'FontSize', 14)

[h,p]=ttest2(plotvar(type==1,:), plotvar(type==0,:))
% sigstar({[1 2], [2,4]}, [0.0122, nan]);