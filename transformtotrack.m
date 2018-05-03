% columns = 'J:O';
% file = 'F:\jochen\180412.xlsx';
% [~, worksheets] = xlsfinfo(file);
% objects = struct([]);
% for sheet = worksheets
%     objects(end+1).Results = xlsread(file,sheet{1},columns);
%     objects(end).File = sheet{1};
% end
objects = allobjects(6);
pr = length(objects);
cellx=cell(pr,1);
celly=cell(pr,1);
weights=cell(pr,1);
point_info=cell(pr,1);
for k=1:pr
    tmp = objects(k).Results;
    tmp = tmp(~isnan(tmp(:,end)),:);
    cellx{k}=tmp(:,2);
    celly{k}=tmp(:,end);
    weights{k} = tmp(:,2)/max(tmp(:,2))*20;
    point_info{k} = repmat(k,size(tmp(:,1)));
end
plot_x=vertcat(cellx{:});
plot_y=vertcat(celly{:});
weights=vertcat(weights{:});
point_info=vertcat(point_info{:});
color_mode = 0;
figure
hold on;
fJKscatterboxplot(plot_x, plot_y, point_info, color_mode, weights)
legend_items = {objects.File};
legend(legend_items, 'Interpreter', 'none', 'Location', 'best');
