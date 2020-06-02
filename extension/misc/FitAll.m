for i = 1:length(Tracks)
    track = Tracks(i);
    if length(track.itrace) == 1
        continue
    end
    f1 = 5;
    npoints = size(track.itrace,1)-f1+1;
    track.FitData = nan(npoints,6,9);
    track.GFPTip = nan(npoints,1);
    track.minima = nan(npoints,2);
    track.Data2 = nan(npoints,5);
    track.GoodData = nan;
    td = track.Data(2:end-10,:);
    td(isnan(td(:,1)),:) = [];
    tipx = interp1(td(:,end), td(:,2), td(1,end):td(end,end));
    tipx = [tipx(1); tipx'; tipx(end).*ones(10,1)];

    if size(track.Data,1) < 20
        warning(num2str(size(track.itrace,1)));
        continue
    end
    stackframes = track.frames(f1:end,2);
    stackframes(stackframes>length(track.TimeInfo)) = length(track.TimeInfo);
    time = track.TimeInfo(stackframes); 
    for frame = f1:size(track.itrace,1)
        iframe = frame-f1+1;
        [num2str(i) ' ' num2str([frame iframe])]

        itrace = track.itrace;
        x = double((((0:length(itrace)-1)-40)*(157/4)) - tipx(1));
        if ~isnan(itrace(frame,1))
            yf = itrace(frame,:);
            [~, seed] = min(abs(x));
            yn = yf-nanmean(itrace(1:6,:));
            [~, tippt1] = min(abs(-x-tipx(iframe)));
            [~, maxid] = max(yn(20:tippt1+30));
            maxid = maxid + 19;
            dist = 25;
            ids = min(tippt1-dist,maxid-25):min(tippt1+dist,maxid);
            ids = ids(ids>0);
            if max(yn(ids)) < 1.5
                goodsign = -1;
            else
                goodsign = 1;
%                 continue
            end
            chptf = findchangepts(yf(ids));
            chptn = findchangepts(yn(ids));
            tippt2 = min(chptf, chptn);
            if mean(yn(tippt1-dist:tippt1-dist+tippt2))>mean(yn(tippt1-dist+tippt2:tippt1+dist))
                tippt2 = max(chptf, chptn);
            end
            tippt2 = min(tippt1-dist,maxid-dist)+tippt2-1;
            yns = smooth(yn,7);
            minbefore = find(islocalmin(yns(1:tippt2)));
            minbeforesel = minbefore(yns(minbefore)<-1 | (yf(minbefore)<max(yf(20:tippt1+30))/2)'); %359
            if ~isempty(minbeforesel)
                tippt2 = minbeforesel(end);
            else
                if ~isempty(minbefore)
                    tippt2 = minbefore(end);
                else
                    tippt2 = 1; %199
                end
            end
            tippt2 = max(tippt2, 10); %294
            try
            [~, peakids] = findpeaks(yn(tippt2:length(yn)), 'NPeaks', 3, 'MinPeakProminence', 0.5, 'MinPeakHeight', -1.5);
            catch
                continue
            end
            peakids = peakids+tippt2-1;
            peaks = yf(peakids);
            if length(peaks) > 1
                if peaks(1)/peaks(2) < 0.85 && peakids(2) - peakids(1) < 30 && min(yf(peakids(1):peakids(2))) > max(0,peaks(1)/2) && ...
                        (peaks(2)-peaks(1))/(peakids(2)-peakids(1)) > 0.5 * (peaks(1)-yf(peakids(1)-10))/10
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
            tippt = tippt3;
            
            
            ys = max(yn)-yn;
            [~, minloc] = findpeaks(ys/max(ys),'MinPeakProminence',0.025);
            leftmin = find((minloc - tippt)<0,1,'last');
            if isempty(leftmin)
                leftmin = 1;
            end
            rightmin = find((minloc - tippt)>0,2);
            minlocright = minloc;
            if isempty(rightmin)
                [~, minlocright] = findpeaks(ys/max(ys),'MinPeakProminence',0.01);
                rightmin = find((minlocright - tippt)>0,2);
            end
            if minlocright(rightmin(1))-tippt < 5 && length(rightmin) == 2
                rightmin = rightmin(2);
            else
                rightmin = rightmin(1);
            end
            minima = [minloc(leftmin) minlocright(rightmin)];
            counter = 0;
            while leftmin-counter > 1 
                if max(yf(minima(1)-10:minima(1)))/yf(tippt) > 0.85 && minloc(leftmin-counter-1) > 10
                    counter = counter + 1;
                    minima(1) = minloc(leftmin-counter);
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
            shifted = 0;
            if length(checklmin) > 2
            [~, checkminloc] = findpeaks(checklmin/max(checklmin),'MinPeakProminence',0.05);
            for k = checkminloc %to exclude parting protofilaments
                if yf(minima(1) + k -1)/yf(tippt) < 0.8
                    minima(1) = start + k -1;
                    shifted = 1;
                end
            end
            end
            
            minbefore = find(islocalmin(yf(1:minima(1)+5)));
            if ~isempty(minbefore) && ~shifted && minbefore(end) < minima(1) && tippt-minima(1)<10
                minima(1) = minbefore(end);
            end
%             minima(1) = max(tippt - 25, minima(1));


            tip = fitFrame.getTip(x(minima(1):minima(2)), yn(minima(1):minima(2)));
            if isnan(tip)
                minima(2) = minlocright(rightmin+1);
                tip = fitFrame.getTip(x(minima(1):minima(2)), yn(minima(1):minima(2))); %track61
                if isnan(tip)
                    tip = fitFrame.getTip(x(minima(1):minima(2)), yf(minima(1):minima(2))+yn(minima(1):minima(2)));
                    if isnan(tip)
                        error('max not captured');
                    end
                end
            end
            track.minima(iframe,:) = minima;
            track.GFPTip(iframe) = tip;
            track.GoodData = goodsign * (1-yf(minima(1))/yf(tippt));

            [~,idTip] = min(abs(x-tip));
            ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
            
%             change = findchangepts(ym);
%             change = x(change);
    
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
            s = [170 500];
            [fits0] = fitFrame.para_fit_erf(xp, yp, bg1, bg2, s);
            [fits1] = fitFrame.para_fit_gauss1(xp, yp, bg1, bg2, s);
            [fits2] = fitFrame.para_fit_gauss2(xp, yp, bg1, bg2, s);
            [fits3] = fitFrame.para_fit_gauss3(xp, yp, bg1, bg2, s);
            [fits4] = fitFrame.para_fit_gauss4(xp, yp, bg1, bg2, s);
            [fits5] = fitFrame.para_fit_exp(xp, yp, bg1, bg2, s);
            fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
            track.FitData(iframe,1:size(fits,1),1:size(fits,2)) = fits;
            if iframe > 1
                pframe = find(~isnan(track.Data2(1:iframe - 1,2)),1,'last');
                if ~isempty(pframe)
                    dt = diff(track.TimeInfo([pframe iframe]));
                    vel = ([fits0(5) fits1(5)]-track.Data2(pframe,2:3))./dt;
                else
                    vel = [nan nan];
                end
            else
                vel = [nan nan];
            end
            track.Data2(iframe,:) = [time(iframe) fits0(5) fits1(5) vel];
        end
    end
    Tracks(i) = track;
end