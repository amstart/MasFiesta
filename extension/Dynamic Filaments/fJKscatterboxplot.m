function fJKscatterboxplot(f, plot_x, plot_y, point_info, names)
[matrix, edgesmid, weights] = histcounts2own(plot_x, plot_y, point_info);
% if color_mode == 0
% %     gscatter(plot_x, plot_y, point_info, [], 'o')
% else
%     colormap(linspecer_modified);
%     scatter(plot_x, plot_y, 500, point_info, 'o');
%     colorbar();
% %     scatter3(plot_x, plot_y, points_info, 50);
% end
%     try
%         cmap = distinguishable_colors(clength);
%     catch
%         cmap = linspecer(clength,'qualitative');
%     end
%     plotc=zeros(size(plotNnew,1),3);
%     for ci=1:size(plotNnew,1)
%         plotc(ci,:)=cmap(find(uniquetracks==plotNnew(ci)),:);
%     end
numcol = length(unique(point_info));
colormap(linspecer(numcol));
% for i=1:numcol
%     now = point_info==i;
%     now = true(size(point_info));
%     s = scatter(f, plot_x(now), plot_y(now), 50, point_info(now)); drawnow;
%     row = dataTipTextRow('TrackId',names(now));
%     s.DataTipTemplate.DataTipRows(end+1) = row;
% end
hold on
s = scatter(f, plot_x, plot_y, 50, point_info); drawnow;

% iosr.statistics.boxPlot(edgesmid, matrix, 'sampleSize', true, 'scatterAlpha', 1, 'showScatter', true, 'medianColor','r', 'showMean', true)
box = iosr.statistics.boxPlot(edgesmid, matrix, 'medianColor','r', 'showOutliers', false, 'showMean', true, 'sampleSize', true, 'sampleFontSize', 14)
for h = [box.handles.box box.handles.medianLines box.handles.lowerWhiskers box.handles.upperWhiskers box.handles.lowerWhiskerTips box.handles.upperWhiskerTips box.handles.means]
    set(h,'HandleVisibility','off');
end
try %matlab 2019
xtickangle(45);
catch
end

function [matrix, edgesmid, weights, nelements] = histcounts2own(plotx, ploty, point_info)
% if ~isempty(weights)
%     weights = weights{1};
% else
%     weights = ones(size(plotx));
% end https://stackoverflow.com/questions/41644022/using-accumarray-for-a-weighted-average
% plotx=plotx(~isnan(plotx));
if 1
    [~, edges, xid] = histcounts(plotx, 14);
%     if length(edges)>7
%         [~, edges, xid] = histcounts(plotx,7);
%     end
else
    [~, edges, xid] = histcounts(plotx,[-0.05:0.05:0.5]);
end
ploty(xid==0) = [];
point_info(xid==0) = [];
xid(xid==0) = [];
idr = ones(size(xid));
for i = 1:length(xid)
    idr(xid==i) = cumsum(idr(xid==i));
end
edgesmid=edges(1:end-1)+diff(edges)/2;
nelements = accumarray(xid, 1);
matrix = nan(max(nelements), length(edgesmid));
weights = nan(size(matrix));
inds = sub2ind(size(matrix), idr, xid);
matrix(inds) = ploty;
weights(inds) = 1./point_info;
