function [out] = getPlotData(track,dims)
%GETPLOTDATA Summary of this function goes here
%   Detailed explanation goes here
out = [];
for i = 1:length(dims)
    d = squeeze(track.FitData(:,dims(i),:));
    t = track.Data2(:,1);
    del = isnan(t) | isnan(d(:,1)) | ~isnan(track.tags(5:end));
    v = nan(size(t));
    v(~del) = [nan; diff(d(~del,5)+d(~del,6))./diff(t(~del))];
    d(del,:) = nan;
    t(del) = nan;
    sigmagauss = d(:,7);
    tau = 1./d(:,8);
    g = nan(size(tau));
    if dims(i) < 6
        g = sqrt(d(:,1)*pi*2.*d(:,7).^2)./157;
    else
        x = (-100:100) * 157/4;
        for j = 1:length(tau)
            expdist = exp((sigmagauss(j)^2*tau(j)^2)/2-tau(j)*x).*erfc((sigmagauss(j)^2*tau(j)-x)/(sigmagauss(j)*sqrt(2)));
            expdist(expdist == inf) = nan;
            expdist = d(j,1) .* expdist/max(expdist);
            g(j) = nansum(expdist)/4;
        end
    end
    out = cat(3, out, [t v d g]);
end