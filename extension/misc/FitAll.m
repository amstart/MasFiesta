for i = 1:length(Tracks)
    track = Tracks(i);
    if length(track.itrace) == 1
        continue
    end
    f1 = 5;
    npoints = size(track.itrace,1)-f1+1;
    track.FitData = nan(npoints,8,9);
    track.GFPTip = nan(npoints,1);
    track.protoF = zeros(npoints,1);
    track.minima = nan(npoints,2);
    track.Data2 = nan(npoints,2);
    track.GoodData = nan(npoints,1);
    td = track.Data(2:end-10,:);
    td(isnan(td(:,1)),:) = [];
    tipx = interp1(td(:,end), td(:,2), td(1,end):td(end,end));
    tipx = [tipx(1); tipx'; tipx(end).*ones(10,1)];

    if size(track.Data,1) < 20% && track.Data(end-10,2) < 400
        warning(num2str(size(track.itrace,1)));
        track.FitData = nan;
        track.GFPTip = nan;
        track.protoF = nan;
        track.minima = nan;
        track.Data2 = nan;
        track.GoodData = nan;
        Tracks(i) = track;
        continue
    end
    stackframes = track.frames(f1:end,2);
    stackframes(stackframes>length(track.TimeInfo)) = length(track.TimeInfo);
    time = track.TimeInfo(stackframes); 
    for frame = f1:size(track.itrace,1)-1
        iframe = frame-f1+1;
        [num2str(i) ' ' num2str([frame iframe])]

        itrace = track.itrace;
        x = double((((0:length(itrace)-1)-28)*(157/4)) - tipx(1));
        if ~isnan(itrace(frame,1))
            yf = itrace(frame,:);
            [~, seed] = min(abs(x));
            yn = yf-nanmean(itrace(1:5,:));
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
            if minloc(1)>11
                minloc = [1 minloc];
            end
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
%                 if isnan(tip)
%                     tip = fitFrame.getTip(x(minima(1):minima(2)), yf(minima(1):minima(2))+yn(minima(1):minima(2)));
                    if isnan(tip)
                        error('max not captured');
                    end
%                 end
            end
            track.minima(iframe,:) = minima;
            track.GFPTip(iframe) = tip;
            track.GoodData(iframe) = goodsign * (1-yf(minima(1))/yf(tippt));

            [~,idTip] = min(abs(x-tip));
            ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
           
            
%             change = findchangepts(ym);
%             change = x(change);
    

            
%             if ~any(x>0)
%                 error('itrace too short');
%             end
            eval = min(length(yn),minima(2)+50);
            
            ytall = track.itracetub(frame,1:end);
            evalt = find((ytall(idTip:end)./(prctile(ytall,90)-prctile(ytall(1:idTip),10)))>0.5,1);
            evalt = min([length(yn)-20,idTip+evalt+20]);

            peakvals = findpeaks(ym(max(minima(1)-20,1):minima(1)),'NPeaks',1,'MinPeakProminence',0.5);
            if ~isempty(peakvals)
                track.protoF(iframe) = max(peakvals);
            end
            begin = max(minima(1), idTip-12);
            xp = x(begin:minima(2));
            xt = x(1:evalt);
            yp = yn(begin:minima(2));
            ypm = ym(begin:minima(2));
            yt = ytall(1:evalt);
            weights = ones(size(yp));
            weightst = ones(size(yt));
%             weights(10:end) = 1 - (1:(length(weights)-9))*0.01;
%             weights(weights < 0) = 0;

            bg2 = 0;
            bg2m = min(ym);
            bg2t = min(yt);
            bg1 = wmean(yn(minima(2):eval), (1-(0:eval-minima(2))/100).^2) - bg2;
            bg1m = wmean(ym(minima(2):eval), (1-(0:eval-minima(2))/100).^2) - bg2m;
            bg1t = wmean(ytall(idTip:evalt), (1-(0:evalt-idTip)/100).^2) - bg2t;
            
            s = [180 190];
            [fits1] = fitFrame.para_fit_exp(xt, yf(1:evalt), bg1m, bg2m, [180 450], nan, nan, 0, idTip, weightst);
            [fits2] = fitFrame.para_fit_exp(xt, yf(1:evalt), bg1m, bg2m, [180 1000], nan, nan, 0, idTip, weightst);
            [fits3] = fitFrame.para_fit_exp(xt, yt, bg1t, bg2t, [180 1000], nan, nan, 0, idTip, weightst);
            [fits4] = fitFrame.para_fit_exp(xp, yp, bg1, bg2, s, s, nan, 0, 0, weights);
            [fits5] = fitFrame.para_fit_exp(xp, ypm, bg1m, bg2m, s, nan, nan, 0, 1, weights);
            [fits6] = fitFrame.para_fit_exp(xp, ypm, bg1m, bg2m, s, nan, nan, 0, 0, weights);
            [fits7] = fitFrame.para_fit_exp(xp, ypm, bg1m, bg2m, s, nan, nan, 1, 0, weights);
            [fits8] = fitFrame.para_fit_exp(xp, ypm, bg1m, bg2m, s, s, nan, 0, 0, weights);
            [fits9] = fitFrame.para_fit_exp(x(1:minima(2)), ym(1:minima(2)), bg1m, bg2m, [180 1000], nan, nan, 0, 0, ones(1,minima(2)));
            [fits10] = fitFrame.para_fit_exp(xt, yt, bg1t, bg2t, s, nan, nan, 0, idTip, weightst);
            [fits11] = fitFrame.para_fit_exp(xt, yt, bg1t, bg2t, [180 450], nan, nan, 0, idTip, weightst);
            
            fits = padcat(fits1, fits2, fits3, fits4, fits5, fits6, fits7, fits8, fits9, fits10, fits11);
            track.FitData(iframe,1:size(fits,1),1:size(fits,2)) = fits;
            SST = sum((yp-mean(yp)).^2);
            track.Data2(iframe,:) = [time(iframe) SST];
        end
    end
    Tracks(i) = track;
end