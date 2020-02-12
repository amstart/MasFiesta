function out = para_fit_fun1(x, y)
lowesty = sort(y);
bg2 = mean(lowesty(1:5));
bg1 = y(end) - bg2;

side = 1;
[maxy, maxid] = max(y);
center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
tip = interp1(maxid-2:maxid+2,x(maxid-2:maxid+2),maxid+center(1));

amp = 100*maxy;
PSF_width = 200;
tau = 10;

suggs = [amp,PSF_width,bg1,bg2,tip,tau];
lb = [0,150,bg1-0.05*bg1,bg2-0.05*bg2,tip-150,0];
ub = [inf,350,bg1+0.05*bg1,bg2+0.05*bg2,tip+150,500];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub,1000);

out = [fits,tip,fvals];