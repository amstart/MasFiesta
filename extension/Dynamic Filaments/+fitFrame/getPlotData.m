function [out] = getPlotData(track,dims)
%GETPLOTDATA Summary of this function goes here
%   Detailed explanation goes here
out = [];
for i = 1:length(dims)
    d = squeeze(track.FitData(:,dims(i),:));
    t = track.Data2(:,1);
    minheight = track.GoodData;
    del = isnan(t) | isnan(d(:,1)) | ~isnan(track.tags(5:end));
    del(find(track.tags(5:end)==6,1):end) = 1;
    v = nan(size(t));
    pos = d(~del,5)+d(~del,8);%track.GFPTip(~del);%
    v(~del) = [nan; diff(pos)./diff(t(~del))];
%     v(v<0) = nan;
    d(del,:) = nan;
    minheight(del,:) = nan;
    sigmagauss = d(:,7);
    tau = 1./d(:,6);
    g = nan(size(tau));
    tg = nan(size(tau));
    ap = nan(size(tau));
    apd = nan(size(tau));
    GFPatSeed = nan(size(tau));
    apf = 0;
    distTosteady = nan(size(tau));
    steady_d = nan(size(tau));
    measured_d = nan(size(tau));
    th = d(:,1)+d(:,3);
    steady_itrace = nanmean(track.itrace(1:5,:));
    x = double((((0:length(track.itrace(1,:))-1)-28)*157/4) - track.Data(2,2));
    for j = 1:length(tau)
        [~,idTip] = min(abs(x-track.GFPTip(j)));
        itrace = track.itrace(j+4,:);
        if track.GFPTip(j) + 2000 < 0
            [~,idSeed] = min(abs(x+250));
            GFPatSeed(j) = mean(itrace(idSeed-9:idSeed));
        end
        MTend = d(j,5);
        if isnan(tau(i)) || tau(i)==inf || tau(i)==0
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
        steady_d(j) = steady_itrace(idTip);
        measured_d(j) = itrace(idTip);
        yn = itrace-steady_itrace;
%         g(j) = sum(yn(idTip:idTip+13)-mean(yn(idTip+14:idTip+20)))/2;
        ptTosteady = find(yn(idTip:end)<yn(idTip)*0.5,1);
        if ~isempty(ptTosteady)
            distTosteady(j) = (ptTosteady - 1)*157/4;
        end
        if ~del(j)
            if ~apf
                apf = 1;
                [~,curr] = min(abs(x-pos(apf)));
            else
                [~,prev] = min(abs(x-pos(apf)));
                apf = apf + 1;
                [~,curr] = min(abs(x-pos(apf)));
            end
            if apf > 1 && prev < curr
                ap(j) = nansum(steady_itrace(prev:curr))/4;
                apd(j) = ap(j)/diff(pos(apf-1:apf));
            end
        end
    end
    out = cat(3, out, [t v d g tg th ap apd minheight steady_d measured_d distTosteady GFPatSeed]);
end