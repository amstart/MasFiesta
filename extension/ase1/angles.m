m = csvread('D:\Jochen\201103 ase1 rescue\dataAngles.csv');

id = m(:,1);
a = m(:,2);
o = m(:,3);
c = m(:,7);
t = m(:,4);
b = m(:,5);

a(a<100) = 180 - a(a<100);
a = a.*2.*pi./360;

b = b ~= 0;

edges = (120:10:180).*2.*pi./360;


f = o == 1 & b == 1;
[counts1b] = histcounts(a(f), edges);
f = o == 1 & b == 0;
[counts1nb] = histcounts(a(f), edges);
f = o == 2 & b == 1;
[counts2b] = histcounts(a(f), edges);
f = o == 2 & b == 0;
[counts2nb] = histcounts(a(f), edges);

rateAP = counts1b./(counts1b+counts1nb);
rateP = counts2b./(counts2b+counts2nb);
figure
polaraxes
polarhistogram('BinEdges',edges,'BinCounts',rateAP);
title('Antiparallel overlaps')
hold on
medges = diff(edges)*0.5 + edges(1:end-1);
polarhistogram('BinEdges',edges,'BinCounts',ones(size(rateP)), 'FaceAlpha', 0);
text(medges,ones(size(medges))-0.1,strsplit(num2str(counts1nb)));
text(medges,ones(size(medges))-0.4,strsplit(num2str(counts1b)));
figure
polaraxes
title('Parallel overlaps')
hold on
polarhistogram('BinEdges',edges,'BinCounts',rateP);
polarhistogram('BinEdges',edges,'BinCounts',ones(size(rateP)), 'FaceAlpha', 0);
text(medges,ones(size(medges))-0.1,strsplit(num2str(counts2nb)));
text(medges,ones(size(medges))-0.4,strsplit(num2str(counts2b)));
% bar([rateAP; rateP]');

l = {{'Single' 'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'0' '42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};