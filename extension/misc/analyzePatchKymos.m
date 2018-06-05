function [ cplot, iplot ] = analyzePatchKymos( patchkymos, bg, backgroundkymo, t, flushins, labels, labelx, pixsize)
%ANALYZEPATCHKYMOS Summary of this function goes here
%   Detailed explanation goes here
%bulk
nMT = length(patchkymos);
background = mean(backgroundkymo,2);
for i = 1:nMT
    if size(bg{i},2)>1
        bg{i} = nanmedian(bg{i},2);
    end
    bg{i} = bg{i} - background;
    patchkymos{i} = patchkymos{i} - repmat(background, 1, size(patchkymos{i},2));
    patchkymos{i}(patchkymos{i}<=0) = nan;
    bg{i}(bg{i}<=0) = nan;
end
allpatchdata = horzcat(patchkymos{:});
allbgdata = horzcat(bg{:});
sumpatchpix = sum(allpatchdata>0,2);
coverage = sumpatchpix ./ size(allpatchdata,2) *100;
patchaverage = nanmean(allpatchdata,2);
bgaverage = nanmean(allbgdata,2);

figure
hold on
plot(t,patchaverage, t, bgaverage);
ylabel('Average intensity [counts]');
xlabel(labelx);
legend({'patches', 'non-patched MT'});
timeplot(t, flushins, labels); drawnow;

normalizedI = patchaverage./max(patchaverage) .* 100;
figure
hold on
plotwithbounds(t,patchkymos,'normalizedI', normalizedI);
ylabel('Normalized Intensity [%]');
xlabel(labelx);
legend({['total (' num2str(nMT) ' MTs)'], ['average of ' num2str(floor(nMT/2)) ' least/most changed patches']})
timeplot(t, flushins, labels);

figure
hold on
plotwithbounds(t,patchkymos,'coverage', coverage);
ylabel('MT coverage [%]');
xlabel(labelx);
legend({['total (' num2str(nMT) ' MTs)'], ['average of ' num2str(floor(nMT/2)) ' least/most covered MTs']})
timeplot(t, flushins, labels);

% figure
% hold on
% changet = [0 diff(t)];
% vel = ([0; diff(sumpatchpix)].*pixsize)./changet';
% plot(t, vel)
% ylabel('Growth rate [nm/s]');
% timeplot(t, flushins, labels); drawnow;

% figure
% hold on
% plot(t, sumpatchpix)
% ylabel('number of patch pixels');
% timeplot(t, flushins, labels); drawnow;
% per MT

% figure
% hold on
% nFrames = size(bg{1},1);
% MTvars = nan(nMT, nFrames, 4);
% legendvec = cell(1,nMT);
% C = linspecer(nMT); 
% for i = 1:nMT
%     legendvec{i} = num2str(i);
%     coverage = sum(patchkymos{i}>0,2) ./ size(patchkymos{i},2);
%     MTvars(i, :, :) = [nanmean(patchkymos{i},2) nanmean(bg{i},2) coverage./max(coverage) [0; diff(sum(patchkymos{i}>0,2))]];
%     plot(t, MTvars(i, :,1), 'color', C(i,:));
% end
% legend(legendvec);
% timeplot(t, flushins, labels); drawnow;
% %MTs averaged

% figure
% hold on
% var = MTvars(:, :, 4)./[diff(t(1:2)) diff(t)];
% plot(t, mean(var), t, mean(var)-std(var), t, mean(var)+std(var));
% timeplot(t);
% ylabel('Change in number of patch pixels (normalized)');

