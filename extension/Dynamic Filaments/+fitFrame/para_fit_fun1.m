function [fits,fvals] = para_fit_fun1(x, y)
bg1 = y(end);
lowesty = sort(y);
bg2 = mean(lowesty(1:5));

[maxy, maxid] = max(y);

amp = 2*maxy-bg1;

suggs = [amp,amp,x(maxid),0,170,bg1,bg2,50];
lb = [0,0,-inf,-1000,150,mean([bg2 bg1]),bg2,1];
ub = [inf,inf,inf,1000,300,bg1,bg2*2,1000];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub,500);

suggs(2) = amp*10000;
ub(4) = 10;
[fit,fval] = fitFrame.fit_fun1(x,y,suggs,lb,ub,500);
fits = vertcat(fits,fit);
fvals = [fvals, fval];

