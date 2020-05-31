function [out] = getPlotData(track,dims)
%GETPLOTDATA Summary of this function goes here
%   Detailed explanation goes here
out = [];
for i = 1:length(dims)
    d = squeeze(track.FitData(:,dims(i),:));
    t = track.Data2(:,1);
    del = isnan(t) | isnan(d(:,1)) | ~isnan(track.tags(5:end));
    v = nan(size(t));
    v(~del) = [nan; diff(d(~del,5))./diff(t(~del))];
    d(del,:) = nan;
    t(del) = nan;
    out = cat(3, out, [t v d]);
end