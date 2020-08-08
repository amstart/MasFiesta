for i=1:length(Tracks)
    if length(Tracks(i).protoF)>1
        Tracks(i).protoFa = [Tracks(i).protoF(:,1)>3 Tracks(i).protoF(:,1)>3];
        for j = 2:length(Tracks(i).protoFa)
            Tracks(i).protoFa(j,2) = ~Tracks(i).protoFa(j-1,1) & Tracks(i).protoFa(j,1);
        end
        Tracks(i).protoFn = nansum(Tracks(i).protoFa(:,2));
    else
        Tracks(i).protoFn = 0;
        Tracks(i).protoFa = nan;
    end
end
% 
% 
% figure
% hold on
% for i=1:length(Tracks)
%     track = Tracks(i);
%     GFPtip = track.GFPTip;
%     select = GFPtip < -400;
%     select(isnan(GFPtip)) = 1;
%     select(end-9:end) = 0;
%     select(find(select==0,1):end) = 0;
%     select(isnan(GFPtip)) = 0;
%     select(~isnan(track.tags(5:end))) = 0;
%     bg = nanmean(track.itrace(1:6,:));  
%     itrace = track.itrace(5:end,:);
%     itrace = itrace(select,:);
%     GFPtip = GFPtip(select);
%     x = repmat(double((((0:length(itrace(1,:))-1)-40)*157/4)),length(GFPtip),1) - track.Data(2,2);
%     x = x - repmat(GFPtip,1,size(x,2));
%     x(abs(x) > 1000) = nan;
% 
%     itracenorm = itrace;
%     for j = 1:size(itrace,1)
%         [~,idx] = min(abs(x(j,:)));
%         ym = itrace(j,:)-bg;   
%         itrace(j,:) = [itrace(j,1:idx) ym(idx+1:end)+itrace(j,idx+1)-ym(idx+1)];
%         itracenorm(j,:) = itrace(j,:)./itrace(j,idx);
%     end
%     x = x + repmat(GFPtip,1,size(x,2));
%     for j = 1:size(x,1)
%         plot(x(j,:),itracenorm(j,:),'k');
%     end
% end