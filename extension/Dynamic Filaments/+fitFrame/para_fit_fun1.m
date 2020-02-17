function [out] = para_fit_fun1(x, y)
bg2 = y(1);
bg1 = y(end) - bg2;

side = 1;
[maxy, maxid] = max(y);
center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
tip = interp1(maxid-2:maxid+2,x(maxid-2:maxid+2),maxid+center(1));

amp = maxy-bg1;
PSF_width = 170;
tau = 1;

a = 500;
b = 500;

suggs = [amp,PSF_width,bg1,bg2,tip,0,tau];
lb = [0,130,bg1,bg2,tip-a,-b,0];
ub = [inf,350,bg1,bg2,tip+a,b,500];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub);

out = [fits,tip,fvals];