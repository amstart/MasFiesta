function [fit,fval] = fitConvolutedExponential(x,y,sugg,lb,ub)
    % Fit of the data x,y to the convoluted exponential, sugg is the
    % initial guess for the parameters
    
    
    % Function that gives a weight sum(abs(data - prediction)), I think
    % is better to fit to the absolute value rather than the square.
    f = @ (pars) sum((convolutedExponential(x,pars) - y).^2) ;
    
    % Some random options for the optimization
    opts = optimset('MaxFunEvals',5000, 'MaxIter',1000);
    
    % Do the fitting
    [fit,fval] = fminsearchbnd(f,sugg,lb,ub,opts);
    
    
end

