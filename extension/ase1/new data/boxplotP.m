function box=boxplotP(d,g,g2,w,f,l)
%BOXPLOTP Summary of this function goes here
%   Detailed explanation goes here
if isempty(f)
    f = true(size(d));
end
d = d(f);
g = g(f);
g2 = g2(f);
if ~isempty(w)
    w = w(f);
end
if isempty(g2)
    g2 = ones(size(g));
end
idx = unique(g);
idy = unique(g2);
out = histc(g,idx);
out2 = histc(g2,idy);
matrix = nan(max(out),length(idx),length(idy));
wmatrix = nan(max(out),length(idx),length(idy));
for i = 1:length(idx)
    for j = 1:length(idy)
        dat = g==idx(i) & g2==idy(j);
        matrix(1:sum(dat),i,j) = d(dat);
        if ~isempty(w)
            wmatrix(1:sum(dat),i,j) = w(dat);
        end
    end
end
figure
if ~isempty(w)
    box =iosr.statistics.boxPlot(matrix,'weights',wmatrix, 'sampleSize', true, 'notch', false, 'boxColor', 'auto', 'medianColor','k');
else
    box = iosr.statistics.boxPlot(matrix, 'sampleSize', true, 'notch', false, 'boxColor', 'auto', 'medianColor','k');
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
set(gca, 'FontSize', 14);