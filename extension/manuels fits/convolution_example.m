%% Fixed parameters

microsc_resolution = 0.157;
PSF_width = 0.17;

%% Parameters that can change

% The intensity level in the microtubule
bg1=0.2;
% The intensity level outside the microtubule
bg2=0.05;
% The lambda of the exponential (in um)
lambda = 0.4;
% The value of the exponential at x=0 above the background bg1
Amp = 2;

%% Making the data

% We make a series of values on the microtubule
% x is the position in um
x = linspace(0,3);
% y is the signal (exponential + background 1)
y = Amp*exp(-x/lambda)+bg1;

% We make a series of value outside the microtubule
% x2 is the position
% y2 is the signal (background 2)

x2 = linspace(-3,0);
x2 = x2(1:end-1);
y2 = zeros(size(x2));
y2(:) = bg2;

% We concatenate them

y = [y2 y];
x = [x2 x];

%% Applying a gaussian convolution

x_res = x(2)-x(1);
y_conv = imgaussfilt(y,PSF_width/x_res);

%% Plotting
figure;
hold on
plot(x,y,'DisplayName','Source')
plot(x,y_conv,'DisplayName','Convoluted')

% some points (in um), to check that interpolation of the function
% convolutedExponential works well.
x3 = -1:0.25:2;

scatter(x3,convolutedExponential(x3,[bg1,bg2,lambda,Amp]),'DisplayName','Convouted-Interpolated')
ylim([0,inf])
legend()

