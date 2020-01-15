function [fits,fvals,xn,yn] = DoFitConvolutedExponential(x, y)
range = 6:min(45, length(x));
[~,locs] = findpeaks(y(range).*normpdf(x(range),0,1),'NPeaks',1, 'SortStr', 'descend');
peakid = locs + 5;
minima = unique([1 find(islocalmin(y,'MinSeparation',3)), length(y)]);
if isempty(peakid)
    fits = nan;
    fvals = nan;
    xn = nan;
    yn = nan;
    return
end
findmin = minima - peakid;
[~, closestmin] = min(abs(findmin));
if findmin(closestmin) < 0
    left = closestmin;
else
    left = closestmin - 1;
end
right = left+1;
try
if y(minima(left))-y(minima(left)-2) <  0
    left = left-1;
end
catch
end
try
if y(minima(right)+2)-y(minima(right)) <  0
    right = right+1;
end
catch
end

leftmin = max(minima(left),peakid-10);
rightmin = min(minima(right),peakid+15);

a = movmean([nan nan diff(diff(y))],3);
for i = 11:rightmin-peakid
    if a(rightmin)<0
        rightmin = rightmin -1;
    end
end
% for i = 11:peakid-leftmin
%     if a(leftmin)<0
%         leftmin = leftmin + 1;
%     end
% end
    

xn = x(leftmin:rightmin);
yn = y(leftmin:rightmin);

bg1 = yn(end);
lowesty = sort(y);
bg2 = mean(lowesty(1:5));

[maxy, maxid] = max(yn);

suggs = [2*maxy-bg1,xn(maxid),0,0.17,bg1,bg2,0];
lb = [0,-inf,-1,0.15,mean([bg2 bg1]),bg2,-0.5];
ub = [inf,inf,1,0.3,bg1,bg2*2,0.5];

% [fits,fvals] = fitConvolutedExponential(xn,yn,suggs,lb,ub,0.25);
% 
% [fit,fval] = fitConvolutedExponential(x,y,suggs,lb,ub,0.25);
% fits = vertcat(fits,fit);
% fvals = [fvals, fval];
% [fit,fval] = fitConvolutedExponential(xn,yn,suggs,lb,ub,0.5);
% fits = vertcat(fits,fit);
% fvals = [fvals, fval];
% [fit,fval] = fitConvolutedExponential(x,y,suggs,lb,ub,0.5);
% fits = vertcat(fits,fit);
% fvals = [fvals, fval];

lb(end) = 0;
ub(end) = 0;

[fits,fvals] = fitConvolutedExponential(xn,yn,suggs,lb,ub,0.3);


[fit,fval] = fitConvolutedExponential(x,y,suggs,lb,ub,0.3);
fits = vertcat(fits,fit);
fvals = [fvals, fval];
% [fit,fval] = fitConvolutedExponential(xn,yn,suggs,lb,ub,0.3);
% fits = vertcat(fits,fit);
% fvals = [fvals, fval];
[fit,fval] = fitConvolutedExponential(x,y,suggs,lb,ub,0.5);
fits = vertcat(fits,fit);
fvals = [fvals, fval];

