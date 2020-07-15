function [out] = getPlotData(track,dims)
%GETPLOTDATA Summary of this function goes here
%   Detailed explanation goes here
out = [];
for i = 1:length(dims)
    d = squeeze(track.FitData(:,dims(i),:));
    t = track.Data2(:,1);
    del = isnan(t) | isnan(d(:,1)) | ~isnan(track.tags(5:end));
    v = nan(size(t));
    pos = d(~del,5)+d(~del,6);
    v(~del) = [nan; diff(pos)./diff(t(~del))];
    d(del,:) = nan;
    sigmagauss = d(:,7);
    tau = 1./d(:,8);
    g = nan(size(tau));
    tg = nan(size(tau));
    ap = nan(size(tau));
    apf = 0;
    th = d(:,1)+d(:,3);
    static_itrace = nanmean(track.itrace(1:6,:));
    x = double((((0:length(track.itrace(1,:))-1)-40)*157/4) - track.Data(2,2));
    for j = 1:length(tau)
        [~,idTip] = min(abs(x-track.GFPTip(j)));
        itrace = track.itrace(j+4,:);
        MTend = d(j,5);
        if dims(i) < 6
            dist = normpdf(x,MTend,sigmagauss(j));
        else
            dist = exp((sigmagauss(j)^2*tau(j)^2)/2-tau(j)*(x-MTend)).*erfc((sigmagauss(j)^2*tau(j)-(x-MTend))/(sigmagauss(j)*sqrt(2)));
            dist(dist == inf) = nan;
        end
        dist = d(j,1) .* dist/max(dist);
        g(j) = nansum(dist)/4;
        if g(j) == 0
            g(j) = nan;
        end
        [~,seed] = min(abs(x));
        tg(j) = (nansum(dist(1:idTip)) + nansum(itrace(idTip+1:seed)) + nansum(dist(seed+1:end)))/4;
        if tg(j) == 0
            tg(j) = nan;
        end
        if ~del(j)
            if ~apf
                apf = 1;
                continue
            end
            [~,prev] = min(abs(x-pos(apf)));
            apf = apf + 1;
            [~,curr] = min(abs(x-pos(apf)));
            if prev < curr
                ap(j) = nansum(static_itrace(prev:curr))/4;
%                 ap(j) = ap(j)/diff(pos(apf-1:apf));
            end
        end
    end
    out = cat(3, out, [t v d g tg th ap]);
end