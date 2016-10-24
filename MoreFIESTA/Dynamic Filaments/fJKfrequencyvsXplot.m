function fJKfrequencyvsXplot(plotx, ploty, plotN, selectedtracks, ploteventends, units)
[edgesmid, edges, sumy, sumysel] = histcounts2(plotx, ploty, plotN);
set(gca, 'Ticklength', [0 0]);
N = histcounts(ploteventends, edges);
Nselected = histcounts(ploteventends(selectedtracks&~isnan(ploteventends)), edges);
plotynew=N./sumy;
bar(edgesmid, plotynew, 'r');
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
    if sumysel(m) && abs(plotynew(m))
        strlabel = {[num2str(plotynew(m), 2) ' per ' units{2}], ...
            ['N=' num2str(N(m)) ' (' num2str(Nselected(m)) ')'], [num2str(sumy(m),'%1.1f') ' ' units{2}], ['(' num2str(sumysel(m),'%1.1f') ' ' units{2} ')']};
    elseif abs(plotynew(m))>0
        strlabel = {[num2str(plotynew(m), 2) ' per ' units{2}], ...
            ['N=' num2str(N(m)) ' (' num2str(Nselected(m)) ')'], [num2str(sumy(m),'%1.1f') ' ' units{2}]};
    elseif sumysel(m)
        strlabel = {[num2str(sumy(m),'%1.1f') '' units{2}] ['(' num2str(sumysel(m),'%1.1f') ' ' units{2} ')']};
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


function [edgesmid, edges, sumy, sumysel] = histcounts2(plotx, ploty, plotN)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
plotx=plotx(~isnan(plotx));
plotsel=ploty;
plotsel(~plotN(:,2))=deal(0);
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
binvecsel=cell(numel(edges)-1,1);
for m=1:length(xid)
    if isempty(binvec{xid(m)})
        binvec{xid(m)}=ploty(m);
    else
        binvec{xid(m)}=[binvec{xid(m)}; ploty(m)];
    end
    if isempty(binvecsel{xid(m)})
        binvecsel{xid(m)}=plotsel(m);
    else
        binvecsel{xid(m)}=[binvecsel{xid(m)}; plotsel(m)];
    end
end
sumy=zeros(1,length(binvec));
sumysel=zeros(1,length(binvec));
edgesmid=edges(1:end-1)+diff(edges)/2;
for m=1:length(binvec)
    sumy(m)=nansum([binvec{m}]);
    sumysel(m)=nansum([binvecsel{m}]);
end