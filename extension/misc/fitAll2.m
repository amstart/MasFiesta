notfit = [];
for i = 1:length(Tracks)
    track = Tracks(i);
    if length(track.itrace) == 1
        continue
    end
    f1 = 5;
    
    if size(track.Data,1) < 20% && track.Data(end-10,2) < 400
        continue
    end
    
    td = track.Data(2:end-10,:);
    td(isnan(td(:,1)),:) = [];
    tipx = interp1(td(:,end), td(:,2), td(1,end):td(end,end));
    tipx = [tipx(1); tipx'; tipx(end).*ones(10,1)];

    stackframes = track.frames(f1:end,2);
    stackframes(stackframes>length(track.TimeInfo)) = length(track.TimeInfo);
    time = track.TimeInfo(stackframes); 
    for frame = f1:size(track.itrace,1)
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
            
            if yn(maxid) < 0
                maxidold = maxid;
                [~, maxid] = max(yn(maxidold:maxidold+20));
                maxid = maxidold + maxid - 1;
            end

            [~,idTip] = min(abs(x-track.GFPTip(iframe)));
            if abs(maxid-idTip) > 1
                if ~ismember([i frame], notfit1(:,1:2), 'rows')
                    figure; hold on; plot(yf); plot(yn);vline(maxid,'b:');vline(idTip,'g:');vline(tippt1)
                end
                notfit = [notfit; i frame maxid-idTip];
            end

%             [~,idTip] = min(abs(x-tip));
%             ym = [yf(1:idTip) yn(idTip+1:end)+yf(idTip+1)-yn(idTip+1)];
%            
%             
%     
%             xp = x(idTip-5:minima(2));
%             
% 
%             eval = min(length(ym),minima(2)+99);
%             
%             bg2 = max(min(ym(1:40)),0);
%             
%             yp = yn(idTip-5:minima(2));

        end
    end
end