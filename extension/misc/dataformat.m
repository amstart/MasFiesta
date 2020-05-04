for i = 1:length(Tracks)
    d = Tracks(i).Data;
    if length(d) > 1 && Tracks(i).Shrinks
        f = d(:,end);
        fn = f(1):f(end);
        if isnan(d(1))%length(fn) > length(f)
            continue
            for j = 1:length(d(:,end))
                dn = interp1(f,d,fn);
            end
            dn(:,end) = fn;
            missingid = setdiff(fn,f) - fn(1) + 1;
            dn(missingid,1:end-1) = nan;
            Tracks(i).Data = [nan(1,6); dn; nan(10,6)];
        else
            Tracks(i).Data = [nan(1,6); d; nan(10,6)];
        end
    end
end