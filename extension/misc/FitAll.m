for i = 1:10
    track = Tracks(i);
    track.FitData = nan(size(track.Data,1),6,9,3);
    track.GFPTip = nan(size(track.Data,1),1);
    tipx = track.Data(:,2);
    if length(track.itrace) == 1
        continue
    end
    if isnan(track.itrace(1,1))
        warning(num2str(size(track.itrace,1)));
        continue
    end
    for frame = 2:size(Tracks(i).Data,1)
        itrace = track.itrace;
        x = double((((0:length(itrace)-1)-40)*(157/4)) - tipx(1));
        track.minima = nan(size(track.x_sel,1),2);
        if ~isnan(itrace(frame,1))
            yn = itrace(frame,:)-itrace(1,:);
            [~, tippt] = min(abs(-x-tipx(frame)));
            [~, tippt] = findpeaks(yn(10:tippt+12), 'SortStr', 'descend', 'NPeaks', 1);
            tippt = tippt+9;
            tip = fitFrame.getTip(x(tippt-2:tippt+2), yn(tippt-2:tippt+2));
            track.GFPTip(frame) = tip;
            
            
            [~,idTip] = min(abs(x-tip));
            ym = [itrace(frame,1:idTip) yn(idTip+1:end)+itrace(frame,idTip+1)-yn(idTip+1)];
            ys = max(yn)-yn;
            [~, minloc] = findpeaks(ys/max(ys),'MinPeakProminence',0.01);
            minima = [find((minloc - tippt)<0,1,'last') find((minloc - tippt)>0,1)];
            minima = minloc(minima);
            track.minima(frame,:) = minima;
            ally = [itrace(frame,:); ym; yn];
            xp = x(minima(1):minima(2));
            
            for j = 1:3
                y = ally(j,:);
                bg2 = max(min(y(1:40)),0);
                yp = y(minima(1):minima(2));
                bg1 = yp(end) - bg2;
                if yp(1) == max(yp) || yp(2) == max(yp)
                    continue
                end
%                 i
%                 j
                [fits0] = fitFrame.para_fit_erf(xp, yp, bg1, bg2);
                [fits1] = fitFrame.para_fit_gauss1(xp, yp, bg1, bg2);
                [fits2] = fitFrame.para_fit_gauss2(xp, yp, bg1, bg2);
                [fits3] = fitFrame.para_fit_gauss3(xp, yp, bg1, bg2);
                [fits4] = fitFrame.para_fit_gauss4(xp, yp, bg1, bg2);
                [fits5] = fitFrame.para_fit_exp(xp, yp, bg1, bg2);
                fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
                track.FitData(frame,1:size(fits,1),1:size(fits,2),j) = fits;
            end
        end
    end
    Tracks(i) = track;
end