function multitrack(f, cellx, celly, point_info, names)
hold on
for i=1:length(cellx)
    p = plot(f, cellx{i}, celly{i}+(i-1)*10);
    frame = find(~isnan(celly{i}),1); 
    plot(f, [cellx{i}(frame)-1 cellx{i}(frame)], [(i-1)*10 celly{i}(frame)+(i-1)*10], ':', 'Color', get(p, 'Color'));
    row = dataTipTextRow('TrackId',names{i});
    p.DataTipTemplate.DataTipRows(end+1) = row;
end