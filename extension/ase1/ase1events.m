function [outputArg1,outputArg2] = ase1events(e,dx,t,grouping,f,mov)
%ASE1EVENTS Summary of this function goes here
%   Detailed explanation goes here
grouping = grouping(f);
e = e(f);
t = t(f);
dx = dx(f);
mov = mov(f);

[gu,~,guid] = unique(grouping);
[mu,~,mid] = unique(mov);
figure
hold on
dat = [];
alldat = [];
datx = [];
alldatx = [];

for i = 2:length(gu)
    for j = 1:length(mu)
        ids = guid==i & mid==j;
        [name,~,id] = unique(t(ids));
        ae = accumarray(id,e(ids));
        adx = accumarray(id,dx(ids));
        dat = [dat ae./adx];
        datx = [datx adx];
    end
    alldat = cat(3,alldat,dat);
    alldatx = cat(3,alldatx,datx);
    dat = [];
    datx = [];
end
medval = squeeze(mean(alldat,2));
sumdx = squeeze(sum(alldatx,2));
err = squeeze(std(alldat,[],2));
hbar = bar(1:3, medval);
ngroups = size(medval, 1);
nbars = size(medval, 2);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, medval(:,i), err(:,i), 'r', 'LineStyle', 'None');
    text(x - groupwidth/6, medval(:,i)./2, num2str(sumdx(:,i),3));
end
xticks(1:3);
xticklabels({'Single', 'Antiparallel', 'Parallel'});
set(gca, 'FontSize', 14);