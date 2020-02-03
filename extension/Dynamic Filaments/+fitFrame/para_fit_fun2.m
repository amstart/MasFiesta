function [fits,fvals] = para_fit_fun2(x, y)
lowesty = sort(y);
bg2 = mean(lowesty(1:5));
bg1 = y(end) - bg2;

side = 1;
[maxy, maxid] = max(y);
center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
tip = interp1(maxid-2:maxid+2,x(maxid-2:maxid+2),maxid+center(1));

amp = maxy-bg1;
PSF_width = 200;

suggs = [amp,PSF_width,bg1,bg2,tip];
lb = [0,150,0,0,tip-150];
ub = [inf,350,inf,inf,tip+150];

[fits,fvals] = fitFrame.fit_fun2(x,y,suggs,lb,ub,1000);