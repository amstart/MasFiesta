function [fit,fval] = fitConvolutedExponential(x,y,sugg,lb,ub,weights_sigma)
    % Fit of the data x,y to the convoluted exponential, sugg is the
    % initial guess for the parameters
    weights = normpdf(x,sugg(2),weights_sigma);
    % Function that gives a weight sum(abs(data - prediction)), I think
    % is better to fit to the absolute value rather than the square.
    f = @ (pars) sum(((convolutedExponential(x,pars) - y).*weights).^2) ;
    
    % Some random options for the optimization
    opts = optimset('MaxFunEvals',5000, 'MaxIter',1000, 'Display', 'off');
    
    % Do the fitting
    [fit,fval] = fminsearchbnd(f,sugg,lb,ub,opts);
    
    
end

