function [fit,fval,x,y] = DoFitConvolutedExponential(x, y)
[maxy,maxid] = max(y);
halfl = round(length(y)/2);
maxid = min(maxid, round(3/2*halfl))-find(x==0);
bg1 = median(y(end-halfl:end));
bg2 = mean(y(1:8));
overbg1 = y > bg1;
if overbg1(end)
    n = find(~overbg1,1,'last')+1;
    y = y(1:n);
    x = x(1:n);
end
xres = x(2)-x(1);
suggs = [2*maxy,maxid*xres,0.2,mean(y(end-8:end)),bg2,0.17];
lb = [0,-inf,0,bg2,bg2,0.15];
ub = [inf,inf,inf,max(y),bg2,0.19];
[fit,fval] = fitConvolutedExponential(x,y,suggs,lb,ub);