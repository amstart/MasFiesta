function [out] = para_fit_exp(x, y)
bg2 = y(1);
bg1 = y(end) - bg2;

[tip, maxy] = fitFrame.getTip(x,y);

amp = maxy-bg1;
s_sug = 170;
s_l = 130;
s_h = 350;
tau = 1;

a = 500;
b = 500;

suggs = [amp,s_sug,bg1,bg2,tip,0,s_sug,tau];
lb = [0,s_l,bg1,bg2,tip-a,-b,s_l,0];
ub = [inf,s_h,bg1,bg2,tip+a,b,s_h,500];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub);

out = [fits,tip,fvals];