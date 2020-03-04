% function y = alignItrace(ref,arg,refx,argx)
% ref = ref{1};
% y = nan(length(arg)+1, size(ref,2)+20);
% y(1,1:size(ref,2)) = ref(2,:);
% for i = 1:length(arg)
%     dist = max(ceil((refx-argx(i))./39.5+0.5),1);
%     y2 = arg{i}(2,:);
%     y(i+1,dist:dist+length(y2)-1) = y2;
% end
% NOT USED
