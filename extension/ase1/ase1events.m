function [outputArg1,outputArg2] = ase1events(e,dx,t,grouping,f)
%ASE1EVENTS Summary of this function goes here
%   Detailed explanation goes here
grouping = grouping(f);
e = e(f);
t = t(f);
dx = dx(f);

[gu,~,guid] = unique(grouping);

for i = 1:length(gu)
    ids = guid==i;
    [name,~,id] = unique(t(ids));
    ae = accumarray(id,e(ids));
    adx = accumarray(id,dx(ids));
    figure
    bar(ae./adx);
    xticklabels({'Single', 'Antiparallel', 'Parallel'});
    title(gu(i));
end

