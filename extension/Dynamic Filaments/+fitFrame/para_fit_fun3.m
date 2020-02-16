function out = para_fit_fun3(x, y)
bg2 = y(1);
bg1 = y(end) - bg2;

side = 1;
[maxy, maxid] = max(y);
center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
tip = interp1(maxid-2:maxid+2,x(maxid-2:maxid+2),maxid+center(1));

amp = maxy-bg1;
PSF_width = 170;

a = 1000;
b = 250;

suggs = [amp,PSF_width,bg1,bg2,tip,0];
lb = [0,130,bg1,bg2,tip-a,-b];
ub = [inf,350,bg1,bg2,tip+a,b];

[fits,fvals] = fitFrame.fit_fun2(x,y,suggs,lb,ub);
fits(end+1) = nan;

out = [fits,tip,fvals];