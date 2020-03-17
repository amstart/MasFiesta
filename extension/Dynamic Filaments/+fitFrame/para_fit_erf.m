function out = para_fit_erf(x, y, bg1, bg2)
[tip, maxy] = fitFrame.getTip(x,y);

amp = 0;
s_sug = 170;
s_l = 130;
s_h = 350;

a = 1000;
b = 0;

suggs = [amp,s_sug,bg1,bg2,tip,0,0];
lb = [0,s_l,bg1,bg2,tip-a,-b,0];
ub = [0,s_h,bg1,bg2,tip+a,b,0];

[fits,fvals] = fitFrame.fit_fun2(x,y,suggs,lb,ub);

out = [[fits nan],fvals];