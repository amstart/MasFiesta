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

for i = 2:length(gu)
    ids = guid==i;
    [name,~,id] = unique(t(ids));
    ae = accumarray(id,e(ids));
    adx = accumarray(id,dx(ids));
    dat = [dat ae./adx];
end
bar(dat);
xticklabels({'Single', 'Antiparallel', 'Parallel'});