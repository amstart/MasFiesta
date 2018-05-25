columns = 'A:T';
file = 'Y:\Jochen\180412_flushOutAfterDifferentTime\180412.xlsx';
[~, worksheets] = xlsfinfo(file);
% worksheets = {'19_400x_75mM_2min_shrink'};
objects = struct([]);
for sheet = worksheets
    objects(end+1).Results = xlsread(file,sheet{1},columns);
    objects(end).File = sheet{1};
end