pr = length(objects);
cellx=cell(pr,1);
celly=cell(pr,1);
weights=cell(pr,1);
point_info=cell(pr,1);
for k=1:length(objects)-1
    tmp = objects(k).Results;
    if tmp(2,20) == -1
        startflush = tmp(5,20)* tmp(4,20);
        tmp = tmp(~isnan(tmp(:,13)),:);
        tmp2=tmp(:,10);
        tmp2(isnan(tmp2))=0;
        cellx{k}=tmp(:,8)-startflush;
        celly{k}=tmp(:,12);
        weights{k} = abs(tmp2);
        point_info{k} = tmp2;
    end
end
plot_x=vertcat(cellx{:});
plot_y=vertcat(celly{:});
weights=vertcat(weights{:});
point_info=vertcat(point_info{:});
color_mode = 0;
figure
hold on;
fJKscatterboxplot(plot_x, plot_y, point_info, color_mode, weights)
% legend({'not at MT edge', 'at MT edge'})
xlabel('middle time point of track segment [s]');
ylabel('shrink velocity [nm/s]');
legend('different movies');
ylim([0 150]);
% legend_items = {objects.File};
% legend(legend_items, 'Interpreter', 'none', 'Location', 'best');
