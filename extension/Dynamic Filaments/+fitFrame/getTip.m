function [tip, maxy] = getTip(x,y)
%GETTIP Summary of this function goes here
%   Detailed explanation goes here
side = 1;
[maxy, maxid] = max(y);
if maxid == length(y)
    tip = length(y);
else
    center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
    tip = interp1(maxid-2:min(maxid+2,length(y)),x(maxid-2:min(maxid+2,length(y))),maxid+center(1));
end

