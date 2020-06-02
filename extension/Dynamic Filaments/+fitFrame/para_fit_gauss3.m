function out = para_fit_gauss3(x, y, bg1, bg2, s)
[tip, maxy] = fitFrame.getTip(x,y);

amp = maxy-bg1;
s_sug = 170;
s_l = s(1);
s_h = s(2);

a = 1000;
b = 0;

suggs = [amp,s_sug,bg1,bg2,tip,0,s_sug];
lb = [0,s_l,bg1,bg2,tip-a,-b,s_l];
ub = [inf,s_h,bg1,bg2,tip+a,b,s_h];

[fits,fvals] = fitFrame.fit_fun2(x,y,suggs,lb,ub);

out = [[fits nan],fvals];