function [out] = para_fit_exp(x, y, bg1, bg2, se, sg, b)
[tip, maxy] = fitFrame.getTip(x,y);

amp = maxy-(mean([bg1 bg2]));
s_sug = 170;
sg_l = sg(1);
sg_h = sg(2);
se_l = se(1);
se_h = se(2);
tau = 1;

a = 500;

suggs = [amp,s_sug,bg1,bg2,tip,mean(b),s_sug,tau];
lb = [0,se_l,bg1,bg2,tip-a,b(1),sg_l,0];
ub = [inf,se_h,bg1,bg2,tip+a,b(2),sg_h,500];

[fits,fvals] = fitFrame.fit_fun1(x,y,suggs,lb,ub);

out = [fits,fvals];