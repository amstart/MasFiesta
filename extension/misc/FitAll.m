for i = 1:length(Tracks)
    track = Tracks(i);
    track.FitData = nan(size(track.Data,1),6,9,3);
    track.GFPTip = nan(size(track.Data,1),1);
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
        track.minima = nan(size(track.x_sel,1),2);
        if ~isnan(itrace(frame,1))
            yf = itrace(frame,:);
            [~, seed] = min(abs(x));
            testforchange = findchangepts(yf(10:seed));
            yn = yf-itrace(1,:);
            if mean(yf(10+testforchange:seed)) - mean(yf(10:10+testforchange)) < 1 || max(yn) < 1
                track.GoodData = 0;
                continue
            end
            [~, tippt1] = min(abs(-x-tipx(frame)));
            chptf = findchangepts(yf(tippt1-40:tippt1+40));
            chptn = findchangepts(yn(tippt1-40:tippt1+40));
            tippt2 = min(chptf, chptn);
            if mean(yn(tippt1-40:tippt1-40+tippt2))>mean(yn(tippt1-40+tippt2:tippt1+40))
                tippt2 = max(chptf, chptn);
            end
            tippt2 = tippt1-41+tippt2;
            yns = smooth(yn);
            [~, tippt3] = findpeaks(yns(tippt2:length(yn)), 'NPeaks', 1);
            tippt = tippt3+tippt2-1;
            
            
            ys = max(yn)-yn;
            [~, minloc] = findpeaks(ys/max(ys),'MinPeakProminence',0.01);
            minimal = [find((minloc - tippt)<0,1,'last') find((minloc - tippt)>0,1)];
            minima = minloc(minimal);
            counter = 1;
            ytip = yf(tippt);
            while minimal(1) > 1 
                if yf(minima(2)) > 2 && yf(minima(1))/ytip > 0.75
                    minima = minloc(minimal-counter);
                    ytip = max(yf(minima(1):minima(2)));
                    counter = counter + 1;
                else
                    break
                end
            end
            track.minima(frame,:) = minima;
            if x(minima(2)) > - 200
                continue
            end
            track.GoodData = 1;
            tip = fitFrame.getTip(x(minima(1):minima(2)), yf(minima(1):minima(2)));
            track.GFPTip(frame) = tip;

            [~,idTip] = min(abs(x-tip));
            ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
    
            ally = [yf; ym; yn];
            xp = x(minima(1):minima(2));
            
            if ~any(x>0)
                error('itrace too short');
            end
            eval = min(seed+40,minima(2)+99);
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