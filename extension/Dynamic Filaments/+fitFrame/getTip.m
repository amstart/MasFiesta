function [tip, maxy] = getTip(x,y)
%GETTIP Summary of this function goes here
%   Detailed explanation goes here
side = 2;
[maxy, maxid] = max(y);
if maxid == length(y)-1
    side = 1;
end
if maxid == length(y)
    tip = nan;
    maxy = nan;
    return
else
    center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
    tip = interp1(maxid-1:min(maxid+1,length(y)),x(maxid-1:min(maxid+1,length(y))),maxid+center(2));
end

