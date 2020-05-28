for i = 1:length(Tracks)
    data = Tracks(i).FitData;
    if length(data) == 1
        continue
    end
    s = size(data);
    add = nan(s(1),s(2));
    for j = 1:s(2)
        d = squeeze(data(:,j,:));
        add(:,j) = sqrt(d(:,1)*pi*2.*d(:,7).^2)./157;
    end
    Tracks(i).FitData = cat(3,data,add);
end