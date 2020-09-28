x = zeros(1000,1);
x(200:800) = 1;
y=imgaussfilt(x,170);
figure;plot(y./max(y))
hold on
x = zeros(1000,1);
x(500)=1;
y=imgaussfilt(x,170);
plot(y./max(y))