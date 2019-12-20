range = 6:min(45, length(x));
[~,locs] = findpeaks(y(range),'NPeaks',1, 'SortStr', 'descend');
peakid = locs + 5;
minima = unique([1 find(islocalmin(y,'MinSeparation',3)), length(y)]);

findmin = minima - peakid;
[~, closestmin] = min(abs(findmin));
if findmin(closestmin) < 0
    left = closestmin;
else
    left = closestmin - 1;
end
right = left+1;
if peakid - minima(left) ==  1
    left = left-1;
end
if right - peakid ==  1
    right = right+1;
end

leftmin = max(minima(left),peakid-15);
rightmin = min(minima(right),peakid+15);

a = movmean([nan nan diff(diff(y))],3);
for i = 11:rightmin-peakid
    if a(rightmin)<0
        rightmin = rightmin -1;
    end
end
for i = 11:peakid-leftmin
    if a(leftmin)<0
        leftmin = leftmin + 1;
    end
end
    

xn = x(leftmin:rightmin);
yn = y(leftmin:rightmin);

bg1 = yn(end);
lowesty = sort(y);
bg2 = mean(lowesty(1:5));

[maxy, maxid] = max(yn);

suggs = [3*maxy-bg1,xn(maxid),0.2,0.17,bg1,bg2];
lb = [0,-inf,0,0.14,mean([bg2 bg1]),bg2];
ub = [inf,inf,1,0.2,maxy,bg2*2];
[fit,fval] = fitConvolutedExponential(xn,yn,suggs,lb,ub);

hold on
prediction = convolutedExponential(xn,fit);
plot(xn,prediction,'DisplayName','prediction'); drawnow;