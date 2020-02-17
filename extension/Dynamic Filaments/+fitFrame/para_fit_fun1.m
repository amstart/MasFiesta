function [out] = para_fit_fun1(x, y)
bg2 = y(1);
bg1 = y(end) - bg2;

side = 1;
[maxy, maxid] = max(y);
center = centerOfMass(y(maxid-side:maxid+side)) - side - 1;
tip = interp1(maxid-2:maxid+2,x(maxid-2:maxid+2),maxid+center(1));

amp = maxy-bg1;
s_sug = 170;
s_l = 130;
s_h = 350;
tau = 1;

a = 500;
b = 500;

suggs = [amp,s_sug,bg1,bg2,tip,0,tau,s_sug];
lb = [0,s_l,bg1,bg2,tip-a,-b,0,s_l];
ub = [inf,s_h,bg1,bg2,tip+a,b,500,s_h];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub);

out = [fits,tip,fvals];