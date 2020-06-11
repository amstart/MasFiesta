function multitrack(f, cellx, celly, point_info, names)
hold on
factor = median(celly{1})/2;
for i=1:length(cellx)
    p = plot(f, cellx{i}, celly{i}+(i-1)*factor);
    frame = find(~isnan(celly{i}),1); 
    plot(f, [cellx{i}(frame)-1 cellx{i}(frame)], [(i-1)*factor celly{i}(frame)+(i-1)*factor], ':', 'Color', get(p, 'Color'));
    row = dataTipTextRow('TrackId',names{i});
    p.DataTipTemplate.DataTipRows(end+1) = row;
end