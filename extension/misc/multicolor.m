region{1} = 8:8+24;
region{2} = 72:72+21;
region{3} = 100:111;
regionnames = {'patch 1', 'patch 2', 'bg'};
% bgcolor{1} = 1000; %mCherry
% bgcolor{2} = 3850; %GFP
kymo{1} = GFP-1000;
kymo{2} = mCherry-3850;
kymonames = {'mCherry', 'GFP'};
for i = 1:2
    for k = 1:3
        average{i,k} = mean(kymo{i}(:,region{k}),2);
    end
end
figure
hold on
name = {};
for i = 1:2
    for k = 1:3
        plot(average{i,k});
        name = {name [kymonames{i} regionnames{k}]};
    end
end
legend({'GFP patch 1', 'GFP patch 2', 'GFP bg', 'mC patch 1', 'mC patch 2', 'mC bg'});
ylabel('average intensity [counts]');
xlabel('time [s]');
t = 1:size(kymo{1},1)*2.2;
timeplot(t, [1 3], {'109nm tau-mCherry', '117nm tau-GFP'})