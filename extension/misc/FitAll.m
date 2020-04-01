for i = 162:length(Tracks)
    track = Tracks(i);
    track.FitData = nan(size(track.Data,1),6,9,3);
    track.GFPTip = nan(size(track.Data,1),1);
    track.minima = nan(size(track.x_sel,1),2);
    tipx = track.Data(:,2);
    if length(track.itrace) == 1
        continue
    end
    if isnan(track.itrace(1,1)) || size(track.Data,1) < 5
        warning(num2str(size(track.itrace,1)));
        continue
    end
    for frame = 2:size(Tracks(i).Data,1)
        [num2str(i) ' ' num2str(frame)]

        itrace = track.itrace;
        x = double((((0:length(itrace)-1)-40)*(157/4)) - tipx(1));
        if ~isnan(itrace(frame,1))
            yf = itrace(frame,:);
            [~, seed] = min(abs(x));
%             testforchange = findchangepts(yf(10:seed));
            yn = yf-itrace(1,:);
            [~, tippt1] = min(abs(-x-tipx(frame)));
            [~, maxid] = max(yn(20:tippt1+30));
            maxid = maxid + 19;
            ids = min(tippt1-30,maxid-30):min(tippt1+30,maxid);
            ids = ids(ids>0);
            if max(yn(ids)) < 1.5
                track.GoodData = 0;
                continue
            end
            chptf = findchangepts(yf(ids));
            chptn = findchangepts(yn(ids));
            tippt2 = min(chptf, chptn);
            if mean(yn(tippt1-30:tippt1-30+tippt2))>mean(yn(tippt1-30+tippt2:tippt1+30))
                tippt2 = max(chptf, chptn);
            end
            tippt2 = min(tippt1-30,maxid-30)+tippt2-1;
            yns = smooth(yn,7);
            [~, peakids] = findpeaks(yns(tippt2:length(yn)), 'NPeaks', 3, 'MinPeakProminence', 0.5);
            peaks = yf(peakids+tippt2-1);
            if length(peaks) > 1
                if peaks(1)/peaks(2) < 0.85 && ...
                        (peaks(2)-peaks(1))/(peakids(2)-peakids(1)) > 0.5 * (peaks(1)-yf(peakids(1)+tippt2-11))/10
                    if length(peaks) > 2
                        if peaks(3) < peaks(2)
                            tippt3 = peakids(2);
                        else
                            tippt3 = peakids(1);
                        end
                    else
                        tippt3 = peakids(2);
                    end
                else
                    tippt3 = peakids(1);
                end
            else
                tippt3 = peakids(1);
            end
            tippt = tippt3+tippt2-1;
            
            
            ys = max(yn)-yn;
            [~, minloc] = findpeaks(ys/max(ys),'MinPeakProminence',0.025);
%             [~, minloc2] = findpeaks(ys/max(ys),'MinPeakProminence',0.15);
%             dffyf = [nan diff(yf)];
%             diffyf(minloc) > 0;
            minimal = [find((minloc - tippt)<0,1,'last') find((minloc - tippt)>0,1)];
            minima = minloc(minimal);
            counter = 0;
            while minimal(1)-counter > 1 
                if yf(minima(1))/yf(tippt) > 0.85
                    counter = counter + 1;
                    minima(1) = minloc(minimal(1)-counter);
                    [~,tippt] = findpeaks(yf(minima(1):minima(2)),'NPeaks',1, 'SortStr', 'descend');
                    if isempty(tippt)
                        [~,tippt] = findpeaks(yn(minima(1):minima(2)),'NPeaks',1, 'SortStr', 'descend');
                    end
                else
                    break
                end
            end
%             [ymax, tippt] = max(yf(minima(1):minima(2)));
%             start = minima(1)+tippt-1;
%             checkrmin = max(yf(start:minima(2)))-yf(start:minima(2));
%             if length(checkrmin) > 2
%             [~, checkminloc] = findpeaks(checkrmin/max(checkrmin),'MinPeakProminence',0.05);
%             for k = checkminloc
%                 if yf(start + k -1) < minima(2)
%                     minima(2) = start + k -1;
%                 end
%             end
%             end
            start = minima(1);
            checklmin = max(yf(start:tippt))-yf(start:tippt);
            if length(checklmin) > 2
            [~, checkminloc] = findpeaks(checklmin/max(checklmin),'MinPeakProminence',0.05);
            for k = checkminloc %to exclude parting protofilaments
                if yf(minima(1) + k -1)/yf(tippt) < 0.8
                    minima(1) = start + k -1;
                end
            end
            end
%             if tippt == length(minima(1):minima(2))
%                 minima(2) = minloc(minimal(2)-counter+1);
%             end
            track.minima(frame,:) = minima;
            tip = fitFrame.getTip(x(minima(1):minima(2)), yf(minima(1):minima(2)));
            if isnan(tip)
                tip = fitFrame.getTip(x(minima(1):minima(2)), yn(minima(1):minima(2)));
                if isnan(tip)
                    error('max not captured');
                end
            end
            track.GFPTip(frame) = tip;
            if yf(minima(1))/yf(tippt) > 0.8
                track.GoodData = 0;
                continue
            end
            track.GoodData = 1;

            [~,idTip] = min(abs(x-tip));
            ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
    
            ally = [yf; ym; yn];
            xp = x(minima(1):minima(2));
            
            if ~any(x>0)
                error('itrace too short');
            end
            eval = min(length(ym),minima(2)+99);
            for j = 1:3
                y = ally(j,:);
                bg2 = max(min(y(1:40)),0);
                yp = y(minima(1):minima(2));
                ymean = wmean(y(minima(2):eval), 1-(0:eval-minima(2))/100);
                if j == 2
                    if ymean < yp(end)
                        bg1 = ymean - bg2;
                    else
                        bg1 = mean([ymean yp(end)]) - bg2;
                    end
                else
                    bg1 = yp(end) - bg2;
                end
                if yp(1) == max(yp) || yp(2) == max(yp)
                    continue
                end
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