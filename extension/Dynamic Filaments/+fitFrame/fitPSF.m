for i = 1:length(Tracks)
    track = Tracks(i);
    if length(track.FitData) > 1
        for frame = 1:size(track.PSFsample,1)
            if isnan(track.PSFsample(frame, 1))
                track.PSF(frame) = nan;
                continue
            end
            y = track.PSFsample(frame, :);       
            bg2 = min(y);
            bg1 = 0;
            weights = ones(size(y));
            x = (1:9)*157;
            s = [0 500];
            [fits] = fitFrame.para_fit_exp(x, y, bg1, bg2, s, nan, nan, 0, 0, weights);
            track.PSF(frame) = fits(2);
        end
        Tracks(i) = track;
    end
end
