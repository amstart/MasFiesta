dims = 1:6;
for i = 1:length(Tracks)
    Tracks(i).FitData = nan(size(Tracks(i).Data,1),12,6);
    if any(~isnan(Tracks(i).x_sel))
        for frame = 1:size(Tracks(i).Data,1)
            pts = Tracks(i).x_sel(frame,:);
            x = Tracks(i).itrace{frame}(1,pts(1):pts(end));
            y = Tracks(i).itrace{frame}(2,pts(1):pts(end));
            [fits1] = fitFrame.para_fit_fun1(x, y);
            [fits2] = fitFrame.para_fit_fun2(x, y);
            [fits3] = fitFrame.para_fit_fun3(x, y);
            [fits4] = fitFrame.para_fit_fun4(x, y);
            [fits5] = fitFrame.para_fit_fun5(x, y);
            [fits6] = fitFrame.para_fit_fun6(x, y);
            fits = padcat(fits1, fits2, fits3, fits4, fits5, fits6);
            Tracks(i).FitData(frame,1:size(fits,2),dims) = fits';
        end
    end
end