function out = para_fit_fun2(x, y)
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

a = 1000;
b = 0;

suggs = [amp,s_sug,bg1,bg2,tip,0,0];
lb = [0,s_l,bg1,bg2,tip-a,-b,0];
ub = [inf,s_h,bg1,bg2,tip+a,b,0];

[fits,fvals] = fitFrame.fit_fun2(x,y,suggs,lb,ub);

out = [[fits nan],tip,fvals];