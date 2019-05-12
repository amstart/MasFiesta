function fJKscatterboxplot(f, plot_x, plot_y, point_info, color_mode, varargin)
[matrix, edgesmid, nelements] = histcounts2own(plot_x, plot_y);
if color_mode == 0
%     gscatter(plot_x, plot_y, point_info, [], 'o')
else
    colormap(linspecer_modified);
    scatter(plot_x, plot_y, 500, point_info, 'o');
    colorbar();
%     scatter3(plot_x, plot_y, points_info, 50);
end
%     try
%         cmap = distinguishable_colors(clength);
%     catch
%         cmap = linspecer(clength,'qualitative');
%     end
%     plotc=zeros(size(plotNnew,1),3);
%     for ci=1:size(plotNnew,1)
%         plotc(ci,:)=cmap(find(uniquetracks==plotNnew(ci)),:);
%     end
scatter(f, plot_x, plot_y, 50, point_info); drawnow;
colormap(linspecer);
% iosr.statistics.boxPlot(edgesmid, matrix, 'sampleSize', true, 'scatterAlpha', 1, 'showScatter', true, 'medianColor','r', 'showMean', true)
iosr.statistics.boxPlot(edgesmid, matrix, 'medianColor','r', 'showOutliers', false, 'sampleSize', true, 'showMean', true)
xtickangle(45);

function [matrix, edgesmid, nelements] = histcounts2own(plotx, ploty)
% if ~isempty(weights)
%     weights = weights{1};
% else
%     weights = ones(size(plotx));
% end https://stackoverflow.com/questions/41644022/using-accumarray-for-a-weighted-average
% plotx=plotx(~isnan(plotx));
binnum = 0;
if binnum == 0
    [~, edges, xid] = histcounts(plotx);
    if length(edges)>7
        [~, edges, xid] = histcounts(plotx,7);
    end
else
    [~, edges, xid] = histcounts(plotx,binnum);
end
ploty(xid==0) = [];
xid(xid==0) = [];
idr = ones(size(xid));
for i = 1:length(xid)
    idr(xid==i) = cumsum(idr(xid==i));
end
edgesmid=edges(1:end-1)+diff(edges)/2;
nelements = accumarray(xid, 1);
matrix = nan(max(nelements), length(edgesmid));
inds = sub2ind(size(matrix), idr, xid);
matrix(inds) = ploty;
