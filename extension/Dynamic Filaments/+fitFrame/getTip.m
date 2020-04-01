function [tip, maxy] = getTip(x,y)
%GETTIP Summary of this function goes here
%   Detailed explanation goes here
[maxy, maxid] = max(y);
if maxid == length(y) || maxid == 1
    tip = nan;
    maxy = nan;
    return
else
    side = min([3, length(y)-maxid, maxid-1]);
    center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
    tip = interp1(1:length(y),x,maxid+center(2));
end

