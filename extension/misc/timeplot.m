function [] = timeplot(t, flushins, labels)
%TIMEPLOT Summary of this function goes here
%   Detailed explanation goes here
yl = ylim;
ytext = mean(yl)*1.7;
for i = 1:length(flushins)
    if i>1
        text(t(flushins(i)), ytext, labels{i});
        plot([t(flushins(i)) t(flushins(i))], [yl(1) yl(2)], 'Color', 'red'); drawnow;
    else
        text(t(flushins(i)), mean(yl)*1.5, labels{i});
    end
end
% text(t(1), ytext, '33\muM Tau in 50mM');
% text(t(107), ytext, '33\muM Tau in 75mM');
% plot([t(107) t(107)], [yl(1) yl(2)], 'Color', 'red');
% flushin2 = 230;
% text(t(flushin2), ytext, '33\muM Tau in 100mM');
% plot([t(flushin2) t(flushin2)], [yl(1) yl(2)], 'Color', 'red');
% flushin3 = 319;
% text(t(flushin3), ytext, '0\muM Tau in 100mM');
% plot([t(flushin3) t(flushin3)], [yl(1) yl(2)], 'Color', 'red');