function [fit] = fitConvolutedExponential(x,y,sugg)
    % Fit of the data x,y to the convoluted exponential, sugg is the
    % initial guess for the parameters
    
    
    % Function that gives a weight sum(abs(data - prediction)), I think
    % is better to fit to the absolute value rather than the square.
    f = @ (pars) sum(abs(convolutedExponential(x,pars) - y)) ;
    
    % Some random options for the optimization
    opts = optimset('MaxFunEvals',5000, 'MaxIter',1000);
    
    % Do the fitting
    fit = fminsearch(f,sugg,opts);
    
    
end

