m = csvread('D:\Jochen\201103 ase1 rescue\dataDensity.csv');

d = m(:,2)./180;
mov = m(:,3);
c = m(:,4);
o = m(:,5);

o(o==0) = 3;
o(o==2) = 0;
o(o==3) = 2;

f = true(size(o));
l = {{'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};
boxplotP(d,o+c,[],f,l);