function [out] = para_fit_exp(x, y, bg1, bg2, se, sg, b, isexp, iserf, weights)
[tip, maxy] = fitFrame.getTip(x,y);

if iserf
    amp = 0;
    amp_h = 0;
else
    amp = maxy-(mean([bg1 bg2]));
    amp_h = inf;
end

if isexp
    tau = 1;
    tau_h = 1000;
else
    tau = 0;
    tau_h = 0;
end


a = 500;

suggs = [amp,300,bg1,bg2,tip,tau];
lb = [0,se(1),bg1,bg2,tip-a,0];
ub = [amp_h,se(2),bg1,bg2,tip+a,tau_h];

p = [suggs;lb;ub];

if isnan(sg)
    if isnan(b)
        [fits,fvals] = fitFrame.fit_fun1(x,y,p,@fitFrame.fun1noshiftsamesig, weights);
        out = [[fits fits(2) 0],fvals];
    else
        [fits,fvals] = fitFrame.fit_fun1(x,y,[p [mean(b);b(1);b(2)]],@fitFrame.fun1samesig, weights);
        out = [[fits(1:end-1) fits(2) fits(end)],fvals];
    end
else
    if isnan(b)
        [fits,fvals] = fitFrame.fit_fun1(x,y,[p [300;sg(1);sg(2)]],@fitFrame.fun1noshift, weights);
        out = [[fits 0],fvals];
    else
        [fits,fvals] = fitFrame.fit_fun1(x,y,[p [300 mean(b);sg(1) b(1);sg(2) b(2)]],@fitFrame.fun1, weights);
        out = [fits,fvals];
    end
end

