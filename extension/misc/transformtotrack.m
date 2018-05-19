% columns = 'B:P';
% file = 'X:\jochen\180412.xlsx';
% [~, worksheets] = xlsfinfo(file);
% % worksheets = {'19_400x_75mM_2min_shrink'};
% objects = struct([]);
% for sheet = worksheets
%     objects(end+1).Results = xlsread(file,sheet{1},columns);
%     objects(end).File = sheet{1};
% end
pr = length(objects);
cellx=cell(pr,1);
celly=cell(pr,1);
weights=cell(pr,1);
point_info=cell(pr,1);
for k=4:4
    tmp = objects(k).Results;
    tmp = tmp(~isnan(tmp(:,end)),:);
    tmp2=tmp(:,1);
    tmp2(isnan(tmp2))=0;
    cellx{k}=tmp(:,11);
    celly{k}=tmp(:,end);
    weights{k} = tmp(:,2)/max(tmp(:,2))*20;
    point_info{k} = tmp2;
end
plot_x=vertcat(cellx{:});
plot_y=vertcat(celly{:});
weights=vertcat(weights{:});
point_info=vertcat(point_info{:});
color_mode = 0;
figure
hold on;
fJKscatterboxplot(plot_x, plot_y, point_info, color_mode, weights)
legend({'not at MT edge', 'at MT edge'})
xlabel('Middle time point of segment [s]')
ylabel('Velocity [nm/s]')
% legend_items = {objects.File};
% legend(legend_items, 'Interpreter', 'none', 'Location', 'best');
