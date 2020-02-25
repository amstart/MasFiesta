for i = 1:length(Tracks)
    Tracks(i).FitData = nan(size(Tracks(i).Data,1),6,12);
    if any(~isnan(Tracks(i).x_sel))
        for frame = 1:size(Tracks(i).Data,1)
            Tracks(i).x_sel = [Tracks(i).x_sel; nan(size(Tracks(i).Data,1)-size(Tracks(i).x_sel,1),2)];
            if isnan(Tracks(i).x_sel(frame,1))
                continue
            end
            pts = Tracks(i).x_sel(frame,:);
            if ~isempty(Tracks(i).itrace{frame})
                x = Tracks(i).itrace{frame}(1,pts(1):pts(end));
                y = Tracks(i).itrace{frame}(2,pts(1):pts(end));
                [fits0] = fitFrame.para_fit_erf(x, y);
                [fits1] = fitFrame.para_fit_gauss1(x, y);
                [fits2] = fitFrame.para_fit_gauss2(x, y);
                [fits3] = fitFrame.para_fit_gauss3(x, y);
                [fits4] = fitFrame.para_fit_gauss4(x, y);
                [fits5] = fitFrame.para_fit_exp(x, y);
                fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
                Tracks(i).FitData(frame,1:size(fits,1),1:size(fits,2)) = fits;
            end
        end
    end
end