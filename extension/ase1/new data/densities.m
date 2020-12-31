m = csvread('D:\Jochen\201103 ase1 rescue\dataDensity.csv');

d = m(:,2)./172;
mov = m(:,3);
c = m(:,4);
o = m(:,5);

o(o==0) = 4;
o(o==2) = 0;
o(o==4) = 2;

f = o<4;
% l = {{'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel' 'Seed'},...
l = {'Single', 'Antiparallel' 'Parallel'};
box = boxplotP(d,o,c,[],f,l);
ylabel('Ase1-neon density (1/nm)')

medians = [box.handles.medianLines(:).YData];
medians = medians(1:2:end);
medians = medians([1:3 5:7]);
singled = [medians([1 1 1]).*[1 1.8 1.8] medians([4 4 4]).*[1 1.8 1.8]];
overlapd = medians-singled;