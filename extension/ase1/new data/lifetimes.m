m = csvread('D:\Jochen\201103 ase1 rescue\lifetimes.csv');

g = logical(m(:,1));
cens = m(:,2);
o = m(:,1);
c = m(:,11);
mov = m(:,10);
dt = m(:,8);
ex = m(:,9);
dx = m(:,7) .* 64.5438;

dt(ex>0) = ex(ex>0);

dt = dt .* 5;

cens(cens==2) = 0;%for antiparallel OLs, 
%I marked events where the OL disappeared because of shrinking to seed with
%a 2



figure
f = c == 42 & o == 1;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
hold on
f = c == 420 & o == 1;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
f = c == 42 & o == 2;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
f = c == 420 & o == 2;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
h = get(gca, 'Children');
for ah = h
    set(ah, 'LineWidth', 2);
end
legend([h(12) h(9) h(6) h(3)], {'42nM AP', '420nM AP', '42nM P', '420nM P'})
xlabel('time (s)');
ylabel('survival (1)')
figure
f = o == 1;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
hold on
f = o == 0.5;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
f = o == -1;
ecdf(dt(f), 'Censoring', cens(f), 'Function', 'survivor', 'Bounds','on');
h = get(gca, 'Children');
legend([h(9) h(6) h(3)], {'Antiparallel midzone', 'Antiparallel bundle', 'Antiparallel plus meets lattice'})
xlabel('Time (s)');
ylabel('Survival (1)')