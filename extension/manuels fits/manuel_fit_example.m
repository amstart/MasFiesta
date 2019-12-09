%% Parameters

% The intensity level in the microtubule
bg1=0.2;
% The intensity level outside the microtubule
bg2=0.05;
% The lambda of the exponential (in um)
lambda = 0.4;
% The value of the exponential at x=0 above the background bg1
Amp = 2;


%% Make the data

x = linspace(-2,4);
real_parameters = [bg1,bg2,lambda,Amp];
y = convolutedExponential(x,real_parameters);

% Add different noise and try the fit:

for amp_noise = [0.1,0.2,0.4,1]
    
    y_noisy = y+rand(size(y))*amp_noise;
    
    fit = fitConvolutedExponential(x,y_noisy,[y_noisy(1),y_noisy(end),0.6,max(y_noisy)]);
    % Print the fitted values (Note that lambda prediction is quite good
    % despite the noise)
    fit
    prediction = convolutedExponential(x,fit);
    
    figure
    scatter(x,y_noisy,'DisplayName','data')
    hold on
    plot(x,prediction,'DisplayName','prediction')
    legend()
end


