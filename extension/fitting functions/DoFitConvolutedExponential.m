function [fit] = DoFitConvolutedExponential(x, y)
fit = fitConvolutedExponential(x,y,[y(end),0.1,max(y),0],mean(y(1:2)));
% Print the fitted values (Note that lambda prediction is quite good
% despite the noise)
prediction = convolutedExponential(x,mean(y(1:2)),fit);

plot(x,prediction,'DisplayName','prediction'); drawnow;
legend(num2str(fit,2),'Location','best'); drawnow;
