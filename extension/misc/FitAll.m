for i = 1:length(Tracks)
    track = Tracks(i);
    f1 = 5;
    npoints = size(track.itrace,1)-f1+1;
    track.FitData = nan(npoints,6,9);
    track.GFPTip = nan(npoints,1);
    track.minima = nan(npoints,2);
    track.Data2 = nan(npoints,7);
    tipx = interp1(track.Data(:,end), track.Data(:,2), track.Data(1,end):track.Data(end,end));
    tipx = [tipx(1); tipx'; tipx(end).*ones(5,1)];
    if length(track.itrace) == 1
        continue
    end
    if size(track.Data,1) < 10
        warning(num2str(size(track.itrace,1)));
        continue
    end
    stackframes = track.frames(f1:end,2);
    stackframes(stackframes>length(track.TimeInfo)) = length(track.TimeInfo);
    time = track.TimeInfo(stackframes); 
    for frame = f1:size(track.itrace,1)-5
        iframe = frame-f1+1;
        [num2str(i) ' ' num2str(frame)]

        itrace = track.itrace;
        x = double((((0:length(itrace)-1)-40)*(157/4)) - tipx(1));
        if ~isnan(itrace(frame,1))
            yf = itrace(frame,:);
            [~, seed] = min(abs(x));
            yn = yf-nanmean(itrace(1:6,:));
            [~, tippt1] = min(abs(-x-tipx(iframe)));
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

            minimal = [find((minloc - tippt)<0,1,'last') find((minloc - tippt)>0,1)];
            minima = minloc(minimal);
            counter = 0;
            while minimal(1)-counter > 1 
                if yf(minima(1))/yf(tippt) > 0.85
                    counter = counter + 1;
                    minima(1) = minloc(minimal(1)-counter);
                    [~,tippt] = findpeaks(yn(minima(1):minima(2)),'NPeaks',1, 'SortStr', 'descend');
                    if isempty(tippt)
                        [~,tippt] = findpeaks(yf(minima(1):minima(2)),'NPeaks',1, 'SortStr', 'descend');
                    end
                    tippt = tippt + minima(1) - 1;
                else
                    break
                end
            end
            
            if length(minloc) == 1
                continue
            end

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
            
            if max(yf(1:minima(1)-15)) / yf(tippt) > 0.7
                track.GoodData = -1;
                continue
            end
            
            minima(1) = max(tippt - 20, minima(1));

            track.minima(iframe,:) = minima;
            tip = fitFrame.getTip(x(minima(1):minima(2)), yf(minima(1):minima(2)));
            if isnan(tip)
                tip = fitFrame.getTip(x(minima(1):minima(2)), yn(minima(1):minima(2)));
                if isnan(tip)
                    error('max not captured');
                end
            end
            track.GFPTip(iframe) = tip;
            track.GoodData = 1-yf(minima(1))/yf(tippt);

            [~,idTip] = min(abs(x-tip));
            ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
    
            xp = x(minima(1):minima(2));
            
            if ~any(x>0)
                error('itrace too short');
            end
            eval = min(length(ym),minima(2)+99);
            
            bg2 = max(min(ym(1:40)),0);
            yp = ym(minima(1):minima(2));
            ymean = wmean(ym(minima(2):eval), 1-(0:eval-minima(2))/100);

            if ymean < yp(end)
                bg1 = ymean - bg2;
            else
                bg1 = mean([ymean yp(end)]) - bg2;
            end
            [fits0] = fitFrame.para_fit_erf(xp, yp, bg1, bg2);
            [fits1] = fitFrame.para_fit_gauss1(xp, yp, bg1, bg2);
            [fits2] = fitFrame.para_fit_gauss2(xp, yp, bg1, bg2);
            [fits3] = fitFrame.para_fit_gauss3(xp, yp, bg1, bg2);
            [fits4] = fitFrame.para_fit_gauss4(xp, yp, bg1, bg2);
            [fits5] = fitFrame.para_fit_exp(xp, yp, bg1, bg2);
            fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
            track.FitData(iframe,1:size(fits,1),1:size(fits,2)) = fits;
            if iframe > 1
                pframe = find(~isnan(track.Data2(1:iframe - 1,2)),1,'last');
                if ~isempty(pframe)
                    vel = (fits3(5)-track.Data2(pframe,2))/diff(track.TimeInfo([pframe iframe]));
                else
                    vel = nan;
                end
            else
                vel = nan;
            end
            track.Data2(iframe,:) = [time(iframe) fits3(5) vel fits0(5) fits3([1 2 4])];
        end
    end
    Tracks(i) = track;
end