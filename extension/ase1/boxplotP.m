function boxplotP(d,g,w,f,l)
%BOXPLOTP Summary of this function goes here
%   Detailed explanation goes here
d = d(f);
g = g(f);
if ~isempty(w)
    w = w(f);
end
idx = unique(g);
out = histc(g,idx);
matrix = nan(max(out),length(idx));
wmatrix = nan(max(out),length(idx));
for i = 1:length(idx)
    matrix(1:out(i),i) = d(g==idx(i));
    if ~isempty(w)
        wmatrix(1:out(i),i) = w(g==idx(i));
    end
end
figure
if ~isempty(w)
    iosr.statistics.boxPlot(matrix,'weights',wmatrix, 'sampleSize', true, 'notch', true);
else
    iosr.statistics.boxPlot(matrix, 'sampleSize', true, 'notch', true);
end
if ~isempty(l)
    if iscell(l{1})
        labelArray = [l{1}; l{2}];
        clear tickLabels;
        tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
        ax = gca(); 
        ax.XTickLabel = tickLabels; 
    else
        xticklabels(l);
    end
else
    xticklabels(idx);
end
hold on
% [p,tbl,stats]  = anova1(d,g,'off');
% table = multcompare(stats,'Display','off');
% sigstar(mat2cell(table(:,1:2),ones(size(table(:,1)))), table(:,end));
set(gca, 'FontSize', 13);