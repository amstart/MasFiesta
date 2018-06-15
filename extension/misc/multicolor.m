region{1} = [8:8+24 72:72+21];
region{2} = 100:111;
regionnames = {'patched', 'nonpatched'};
% bgcolor{1} = 1000; %mCherry
% bgcolor{2} = 3850; %GFP
kymo{1} = mC;
kymo{2} = GFP;
bg = [mean(mCherry_background,2) mean(GFP_background,2)];
kymonames = {'mCherry', 'GFP'};
for i = 1:2
    for k = 1:2
        average{i,k} = mean(kymo{i}(:,region{k}),2) - bg(:,i);
    end
end
figure
hold on
name = {};
for i = 1:2
    yyaxis left
    if i == 2
        yyaxis right
    end
    for k = 1:2
        plot(average{i,k}(1:60,:));
        name = {name [kymonames{i} regionnames{k}]};
    end
end
legend({'tau-mCherry in patch', 'tau-mCherry not in patch', 'tau-GFP in patch', 'tau-GFP not in patch'});
ylabel('average GFP intensity [counts]');
yyaxis left
ylabel('average mCherry intensity [counts]');
xlabel('time [s]');
t = 1:size(kymo{1},1)*2.2;
timeplot(t, [1 3], {'109nm tau-mCherry', '117nm tau-GFP'})