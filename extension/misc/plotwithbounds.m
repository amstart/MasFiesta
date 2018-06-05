function [ h ] = plotwithbounds(t, kymos, mode, pooleddata)
%PLOTWITHBOUNDS Summary of this function goes here
%   Detailed explanation goes here
nMT = length(kymos);
alldata = nan(length(t),nMT);
for i = 1:nMT
    switch mode
        case 'coverage'
            alldata(:,i) = sum(kymos{i}>0,2) ./ size(kymos{i},2) .* 100;
            alldata(isnan(alldata)) = 0;
        case 'normalizedI'
            [~,id] = max(pooleddata);
            alldata(:,i) = nanmean(kymos{i},2) ./ nanmean(kymos{i}(id,:)) .* 100;
    end
end
alldata = sort(alldata,2);
alldata = alldata(:,~all(isnan(alldata)));
nvalidMTs = size(alldata,2);
lower = nanmean(alldata(:,1:floor(nvalidMTs/2)),2);
upper = nanmean(alldata(:,ceil(nvalidMTs/2):nvalidMTs),2);
plot(t, pooleddata, 'b', t, lower, 'b--', t, upper, 'b--'); drawnow;