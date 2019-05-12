function fJKfrequencyvsXplot(f, plot_x, plot_y, ploteventends, units)
[edgesmid, edges, sumy] = histcounts2(plot_x, plot_y);
set(gca, 'Ticklength', [0 0]);
N = histcounts(ploteventends, edges);
plotynew=N./sumy;
yemptybar = 0.05 * sign(mean(plotynew)) * max(abs(plotynew));
xemptybar = find(N==0);
b = bar(f, edgesmid, plotynew, 'k');
b.FaceColor = 'flat';
fError = sqrt(N)./sumy; %see https://www.bcube-dresden.de/wiki/Error_bars
alpha = 1 - sumy/max(abs(sumy));
scatter(edgesmid(xemptybar)', ones(length(xemptybar),1) * yemptybar, 1000, repmat(alpha(xemptybar)', 1, 3), 'filled');
s = scatter(edgesmid(xemptybar)', ones(length(xemptybar),1) * yemptybar, 1, 'k', 'filled');
e = errorbar(edgesmid, plotynew, fError, 'r.');
for m=1:length(edgesmid)
    b.CData(m,:) = ones(1,3) .* alpha(m);
    if abs(plotynew(m))
        strlabel = {['N=' num2str(N(m))], [num2str(sumy(m),max(2, floor(1+log10(sumy(m))))) ' ' units{2}]};
    else
        strlabel = [num2str(sumy(m),max(2, floor(1+log10(sumy(m))))) '' units{2}];
    end
    if plotynew(m) > 0
        text(double(edgesmid(m)), plotynew(m)/2, strlabel,...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'r', 'FontSize', 12);
    elseif plotynew(m) < 0
        text(double(edgesmid(m)), plotynew(m)/2, strlabel,...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'r', 'FontSize', 12);
    elseif max(plotynew) > 0
        text(double(edgesmid(m)), yemptybar, strlabel, 'HorizontalAlignment', 'center', 'Color', 'r', 'FontSize', 12);
    end
end
legend([b, s, e], {'frequency (N/sum(t))', 'no events in bin', 'square root(N)/sum(t)'});


function [edgesmid, edges, sumy] = histcounts2(plotx, ploty)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
plotx=plotx(~isnan(plotx));
binnum = 0;
if binnum == 0
    [~, edges, xid] = histcounts(plotx);
    if length(edges)>7
        [~, edges, xid] = histcounts(plotx,6);
    end
else
    [~, edges, xid] = histcounts(plotx,binnum);
end
ploty(xid==0) = [];
xid(xid==0) = [];
binvec=cell(numel(edges)-1,1);
for m=1:length(xid)
    if isempty(binvec{xid(m)})
        binvec{xid(m)}=ploty(m);
    else
        binvec{xid(m)}=[binvec{xid(m)}; ploty(m)];
    end
end
sumy=zeros(1,length(binvec));
edgesmid=edges(1:end-1)+diff(edges)/2;
for m=1:length(binvec)
    sumy(m)=nansum([binvec{m}]);
end