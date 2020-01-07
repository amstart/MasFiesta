function [fit,fval] = fitConvolutedExponential_nb(x,y,sugg,lb,ub)
    % Fit of the data x,y to the convoluted exponential, sugg is the
    % initial guess for the parameters
    x = 1:length(x);
    weights = normpdf(x,sugg(2),2);
    % Function that gives a weight sum(abs(data - prediction)), I think
    % is better to fit to the absolute value rather than the square.
    f = @ (pars) sum(((convolutedExponential(x,pars) - y).*weights)^2) ;
    
    % Some random options for the optimization
    opts = optimset('MaxFunEvals',5000, 'MaxIter',1000);
    
    % Do the fitting
    [fit,fval] = fminsearch(f,sugg,opts);
    
    
end

