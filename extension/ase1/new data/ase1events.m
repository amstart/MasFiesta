function [outputArg1,outputArg2] = ase1events(e,dx,t,grouping,f,mov,l)
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
alldate = [];
datx = [];
alldatx = [];

for i = 1:length(gu)
    for j = 1:length(mu)
        ids = guid==i & mid==j;
        [name,~,id] = unique(t(ids));
        ae = accumarray(id,e(ids));
        adx = accumarray(id,dx(ids));
        dat = [dat ae];
        datx = [datx adx];
    end
    alldate = cat(3,alldate,dat);
    alldatx = cat(3,alldatx,datx);
    dat = [];
    datx = [];
end
alldat = alldate./alldatx;
medval = squeeze(median(alldat,2));
meanval = squeeze(wmean(alldat,alldatx,2));
sumdx = squeeze(sum(alldatx,2));
sume = squeeze(sum(alldate,2));
low = meanval-squeeze(min(alldat,[],2));
high = squeeze(max(alldat,[],2))-meanval;
hbar = bar(1:length(medval), meanval);
ngroups = size(medval, 1);
nbars = size(medval, 2);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, meanval(:,i), low(:,i), high(:,i), 'k', 'LineStyle', 'None');
    text(x - groupwidth/6, meanval(:,i)./2, num2str(sume(:,i),3));
end
xticks(1:length(l));
xticklabels(l);
set(gca, 'FontSize', 14);