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


for i=1:length(tracks)
    itrace = track.itrace(5:end,:);
    GFPtip = track.GFPTip;
    itrace = itrace(~isnan(GFPtip),:);
    GFPtip = GFPtip(~isnan(GFPtip));
    x = repmat(double((((0:length(itrace(1,:))-1)-40)*157/4)),length(GFPtip),1);
    x = x - repmat(GFPtip,1,size(x,2));
    plot(x,itrace);
end