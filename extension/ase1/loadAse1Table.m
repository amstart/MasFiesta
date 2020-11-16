m = csvread('D:\Jochen\201103 ase1 rescue\data.csv');

v = m(:,12);
g = logical(m(:,1));
e = m(:,2);
o = m(:,15);
c = m(:,14);
mov = m(:,13);
dt = m(:,11);
dx = m(:,10);

%compare growth vel
f = g;
boxplotP(v,c,dt,f,[]);

%compare shrinking vel
f = ~g %& o~=2;
l = {{'Single' 'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'0' '42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};
boxplotP(v,c+o,dt,f,l);

f = ~g;
ase1events(e,dx,o,c,f);