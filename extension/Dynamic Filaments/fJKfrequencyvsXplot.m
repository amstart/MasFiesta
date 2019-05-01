function fJKfrequencyvsXplot(plot_x, plot_y, ploteventends, units)
[edgesmid, edges, sumy] = histcounts2(plot_x, plot_y);
set(gca, 'Ticklength', [0 0]);
N = histcounts(ploteventends, edges);
plotynew=N./sumy;
plotynew(sumy==0) = 0;
bar(edgesmid, plotynew, 'r');
fError = sqrt(N)./sumy; %see https://www.bcube-dresden.de/wiki/Error_bars
errorbar(edgesmid, plotynew, fError, '.');
if any(plotynew==0)
    dummyvec = double(plotynew==0|isnan(plotynew));
    if max(plotynew) > 0
        dummyvec = dummyvec * 0.05 * max(plotynew);
    else
        dummyvec = dummyvec * 0.05 * min(plotynew);
    end
    bar(edgesmid, dummyvec, 'w');
end
for m=1:length(edgesmid)
    if abs(plotynew(m))
        strlabel = {[num2str(plotynew(m), 2) ' per ' units{2}], ...
            ['N=' num2str(N(m))], [num2str(sumy(m),'%1.1f') ' ' units{2}]};
    else
        strlabel = [num2str(sumy(m),'%1.1f') '' units{2}];
    end
    if plotynew(m) > 0
        text(double(edgesmid(m)), plotynew(m)/2, strlabel,...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    elseif plotynew(m) < 0
        text(double(edgesmid(m)), plotynew(m)/2, strlabel,...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    elseif max(plotynew) > 0
        text(double(edgesmid(m)), dummyvec(m)/2, strlabel, 'HorizontalAlignment', 'center');
    end
end


function [edgesmid, edges, sumy] = histcounts2(plot_x, plot_y)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
plot_x=plot_x(~isnan(plot_x));
binnum = 10;
if binnum == 0
    [~, edges, xid] = histcounts(plot_x);
    if length(edges)>7
        [~, edges, xid] = histcounts(plot_x,7);
    end
else
    [~, edges, xid] = histcounts(plot_x,binnum);
end
binvec=cell(numel(edges)-1,1);
for m=1:length(xid)
    if isempty(binvec{xid(m)})
        binvec{xid(m)}=plot_y(m);
    else
        binvec{xid(m)}=[binvec{xid(m)}; plot_y(m)];
    end
end
sumy=zeros(1,length(binvec));
edgesmid=edges(1:end-1)+diff(edges)/2;
for m=1:length(binvec)
    sumy(m)=nansum([binvec{m}]);
end