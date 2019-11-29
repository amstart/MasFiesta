for i=1:3
    for j=1:size(d{i},2)
    kdata = d{i}{1,j};
    kymo = (nansum(double(kdata), 1)-sum(~isnan(kdata),1).*min(min(double(kdata), [], 1)));
    if isnan(kymo)
        y = NaN;
    else
        N_datapoints = min(6+25, length(kymo));
        y=kymo(1:N_datapoints);
    end
    f{i}{1,j} = y;
    end
end