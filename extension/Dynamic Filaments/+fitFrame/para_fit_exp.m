function [out] = para_fit_exp(x, y, bg1, bg2, se, sg, b)
[tip, maxy] = fitFrame.getTip(x,y);

amp = maxy-(mean([bg1 bg2]));
tau = 1;

a = 500;

suggs = [amp,mean(se),bg1,bg2,tip,tau];
lb = [0,se(1),bg1,bg2,tip-a,0];
ub = [inf,se(2),bg1,bg2,tip+a,500];

p = [suggs;lb;ub];

if isnan(sg)
    [fits,fvals] = fitFrame.fit_fun1(x,y,p,@fitFrame.fun1noshiftsamesig);
    out = [[fits fits(2) 0],fvals];
else
    if isnan(b)
        [fits,fvals] = fitFrame.fit_fun1(x,y,[p [mean(sg);sg(1);sg(2)]],@fitFrame.fun1noshift);
        out = [[fits 0],fvals];
    else
        [fits,fvals] = fitFrame.fit_fun1(x,y,[p [mean(sg) mean(b);sg(1) b(1);sg(2) b(2)]],@fitFrame.fun1);
        out = [fits,fvals];
    end
end

