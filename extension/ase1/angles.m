m = csvread('D:\Jochen\201103 ase1 rescue\dataAngles.csv');

id = m(:,1);
a = m(:,2);
o = m(:,3);
c = m(:,7);
t = m(:,4);
b = m(:,5);

a(a<100) = 180 - a(a<100);
% a = a.*2.*pi./360;

b = b ~= 0;

edges = 138:6:180;


f = o == 1 & b == 1;
[counsts1b] = histcounts(a(f), edges);
f = o == 1 & b == 0;
[counsts1nb] = histcounts(a(f), edges);
f = o == 2 & b == 1;
[counsts2b] = histcounts(a(f), edges);
f = o == 2 & b == 0;
[counsts2nb] = histcounts(a(f), edges);

figure
hold on
rateAP = counsts1b./(counsts1b+counsts1nb);
rateP = counsts2b./(counsts2b+counsts2nb);
bar([rateAP; rateP]');

l = {{'Single' 'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'0' '42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};