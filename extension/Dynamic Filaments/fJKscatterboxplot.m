function fJKscatterboxplot(plot_x, plot_y, point_info, color_mode, varargin)
[out, edgesmid, nelements, allpointsx, allpointsy] = histcounts2own(plot_x, plot_y, varargin);
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
%     scatter(plotxnew, plotynew, 50, plotc, marker{m}); drawnow;
b=boxplot(allpointsy, allpointsx, 'Color', 'k', 'position', unique(allpointsx), 'outliersize', 0.0001);
set(b(:,:),'linewidth',1.5);
 h = findobj(b,'tag','Outliers');
 set(h,'Visible','off');
 h = findobj(b,'tag','Median');
 set(h,'Color','red');
for m=1:length(nelements)
    if nelements(m)>0
        text(double(edgesmid(m)), 100, num2str(nelements(m)), 'HorizontalAlignment', 'center', 'FontSize', 18);
%         text(double(edgesmid(m)), out(m,1), num2str(nelements(m)), 'HorizontalAlignment', 'center', 'FontSize', 18);
        text(double(edgesmid(m)), 80, num2str(out(m,2), 3), 'HorizontalAlignment', 'center', 'FontSize', 18);
    end
end
set(gca,'Color',[0.9 0.9 0.9]);
% ylim([-600 0])

function [out, edgesmid, nelements, allpointsx, allpointsy] = histcounts2own(plotx, ploty, weights)
if ~isempty(weights)
    weights = weights{1};
else
    weights = ones(size(plotx));
end
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
plotx=plotx(~isnan(plotx));
binnum = 0;
if binnum == 0
    [~, edges, xid] = histcounts(plotx);
    if length(edges)>7
        [~, edges, xid] = histcounts(plotx,7);
    end
else
    [~, edges, xid] = histcounts(plotx,binnum);
end
binvec=cell(numel(edges)-1,1);
binedgevec=cell(numel(edges)-1,1);
for m=1:length(xid)
    if xid(m) == 0
        continue
    end
    if isempty(binvec{xid(m)})
        binvec{xid(m)}=[ploty(m) weights(m)];
    else
        binvec{xid(m)}=[binvec{xid(m)}; [ploty(m) weights(m)]];
    end
end
out=zeros(length(binvec),2);
nelements=zeros(1,length(binvec));
edgesmid=edges(1:end-1)+diff(edges)/2;
for m=1:length(binvec)
    if ~isempty(binvec{m})
        values=binvec{m}(:,1);
        weights=binvec{m}(:,2);
        out(m,2)=wmean(values,weights);
    else
        values=[];
        weights=[];
    end
    out(m,1)=nanmedian(values);
    nelements(m)=length(values);
    binedgevec{m}=repmat(edgesmid(m),length(values),1);
end
allpointsx=vertcat(binedgevec{:});
allpointsy=vertcat(binvec{:});
allpointsy=allpointsy(:,1);