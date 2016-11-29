function fJKscatterboxplot(plot_x, plot_y, points_info)
[middle, edgesmid, nelements, allpointsx, allpointsy] = histcounts2(plot_x, plot_y);
gscatter(plot_x, plot_y, points_info, [], 'o')
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
%         hMarkers = plothandle{j}.MarkerHandle;
%         hMarkers.get;
%         hMarkers.EdgeColorData = uint8([allcolors{1};200]);
set(b(:,:),'linewidth',1.5);
 h = findobj(b,'tag','Outliers');
 set(h,'Visible','off');
 h = findobj(b,'tag','Median');
 set(h,'Color','red');
for m=1:length(nelements)
    if nelements(m)>0
        text(double(edgesmid(m)), middle(m), num2str(nelements(m)), 'HorizontalAlignment', 'center', 'FontSize', 18);
    end
end
set(gca,'Color',[0.9 0.9 0.9]);
% ylim([-600 0])

function [middle, edgesmid, nelements, allpointsx, allpointsy] = histcounts2(plotx, ploty)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
plotx=plotx(~isnan(plotx));
binnum = 0;
if binnum == 0
    [~, edges, xid] = histcounts(plotx);
%     if length(edges)>7
%         [~, edges, xid] = histcounts(plotx,0:20:400);
%     end
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
        binvec{xid(m)}=ploty(m);
    else
        binvec{xid(m)}=[binvec{xid(m)}; ploty(m)];
    end
end
middle=zeros(1,length(binvec));
nelements=zeros(1,length(binvec));
edgesmid=edges(1:end-1)+diff(edges)/2;
for m=1:length(binvec)
    middle(m)=nanmedian([binvec{m}]);
    nelements(m)=length([binvec{m}]);
    binedgevec{m}=repmat(edgesmid(m),length(binvec{m}),1);
end
allpointsx=vertcat(binedgevec{:});
allpointsy=vertcat(binvec{:});