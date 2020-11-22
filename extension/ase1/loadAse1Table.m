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
f = g & c>0;
l = {{'Single' 'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'0' '42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};
boxplotP(v,o+c,dt,f,l);
ylabel('Growth velocity [nm/s]');

%compare shrinking vel
f = ~g; %& o~=2;
l = {{'Single' 'Single', 'Antiparallel' 'Parallel' 'Single' 'Antiparallel' 'Parallel'},...
    {'0' '42nM' '42nM' '42nM' '420nM' '420nM' '420nM'}};
boxplotP(v,c+o,dt,f,l);
ylabel('Shrinking velocity [nm/s]');

f = ~g;
ase1events(e,dx./1000,o,c,f,mov);
ylabel('Rescue frequency [1/um]');
legend('42nM','420nM');


figure
f = ~g & c == 42 & o == 0;
ecdf(dx(f), 'Censoring', ~e(f), 'Function', 'survivor', 'Bounds','on');
hold on
f = ~g & c == 42 & o == 1;
ecdf(dx(f), 'Censoring', ~e(f), 'Function', 'survivor', 'Bounds','on');
f = ~g & c == 420 & o == 0;
ecdf(dx(f), 'Censoring', ~e(f), 'Function', 'survivor', 'Bounds','on');
f = ~g & c == 420 & o == 1;
ecdf(dx(f), 'Censoring', ~e(f), 'Function', 'survivor', 'Bounds','on');
h = get(gca, 'Children');
legend([h(12) h(6) h(9) h(3)], {'42nM Single MT', '420nM Single MT', '42nM Crosslinked MT', '420nM Crosslinked MT'})