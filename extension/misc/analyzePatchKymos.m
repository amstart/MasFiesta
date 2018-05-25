function [ cplot, iplot ] = analyzePatchKymos( patchkymos, bg, backgroundkymo, t, flushins, labels, labelx)
%ANALYZEPATCHKYMOS Summary of this function goes here
%   Detailed explanation goes here
%bulk
nMT = length(patchkymos);
background = mean(backgroundkymo,2);
allpatchdata = horzcat(patchkymos{:});
allbgdata = horzcat(bg{:});
sumpatchpix = sum(allpatchdata>0,2);
coverage = sumpatchpix ./ size(allpatchdata,2) *100;
patchaverage = nanmean(allpatchdata,2)-background;
bgaverage = nanmean(allbgdata,2)-background;
figure
hold on
plot(t,patchaverage, t, bgaverage);
ylabel('Average intensity [counts]');
xlabel(labelx);
legend({'patches', 'non-patched MT'});
timeplot(t, flushins, labels); drawnow;
figure
hold on
MTcoverage = nan(length(t),nMT);
for i = 1:nMT
    MTcoverage(:,i) = sum(patchkymos{i}>0,2) ./ size(patchkymos{i},2) .* 100;
end
MTcoverage = sort(MTcoverage,2);
lowercover = mean(MTcoverage(:,1:floor(nMT/2)),2);
uppercover = mean(MTcoverage(:,ceil(nMT/2):nMT),2);
plot(t, coverage, 'b', t, lowercover, 'b--', t, uppercover, 'b--'); drawnow;
ylabel('MT coverage [%]');
xlabel(labelx);
legend({['total (' num2str(nMT) ' MTs)'], ['average of ' num2str(floor(nMT/2)) ' least/most covered MTs']})
timeplot(t, flushins, labels);
% figure
% hold on
% plot(t, change)
% ylabel('Change in number of patch pixels');
% timeplot(t);
% figure
% hold on
% plot(t, sumpatchpix)
% ylabel('number of patch pixels');
% timeplot(t);
%per MT
% figure
% hold on
% MTvars = nan(nMT, nFrames, 4);
% legendvec = cell(1,nMT);
% C = linspecer(nMT); 
% for i = 1:nMT
%     legendvec{i} = num2str(i);
%     coverage = sum(patchkymos{i}>0,2) ./ size(patchkymos{i},2);
%     MTvars(i, :, :) = [nanmean(patchkymos{i},2) nanmean(bg{i},2) coverage./max(coverage) [0; diff(sum(patchkymos{i}>0,2))]];
%     plot(t, MTvars(i, :,4), 'color', C(i,:));
% end
% legend(legendvec);
% timeplot(t);
% %MTs averaged
% figure
% hold on
% var = MTvars(:, :, 4)./[diff(t(1:2)) diff(t)];
% plot(t, mean(var), t, mean(var)-std(var), t, mean(var)+std(var));
% timeplot(t);
% ylabel('Change in number of patch pixels (normalized)');

