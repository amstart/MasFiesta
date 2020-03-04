%NOT USES

% for i = 1:length(Tracks)
%     Tracks(i).itrace2 = nan;
%     if Tracks(i).PreviousEvent && Tracks(i).Shrinks && diff(Tracks(i).Data([end 1],1)) > 20
%         bg = Tracks(i-1).itrace(end-2:end);
%         bgx = Tracks(i-1).Data(end-2:end,2);
%         y = alignItrace(bg(end),bg(1:2),bgx(end),bgx(1:2));
%         bgy = nanmean(y);
%         y = alignItrace(bg(end),Tracks(i).itrace,bgx(end),Tracks(i).Data(:,2));
%         yfrac = y ./ repmat(bgy, size(y,1),1);
%         ysub = y - repmat(bgy, size(y,1),1);
% %         Tracks(i).itrace2 = cat(3, bgx(end)+40*39.5, y, yfrac, ysub);
%     end
% end
% % figure('Name',['Measured Data' num2str(i)]);
% % plot(y')
% % figure('Name',['BFrac' num2str(i)]);
% % plot(yfrac')
% % figure('Name',['BSub' num2str(i)]);
% % plot(ysub')