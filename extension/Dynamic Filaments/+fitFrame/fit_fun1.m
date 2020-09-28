function [fit,fval] = fit_fun1(x,y,p, fun, weights)
    % Fit of the data x,y to the convoluted exponential, sugg is the
    % initial guess for the parameters
    % Function that gives a weight sum(abs(data - prediction)), I think
    % is better to fit to the absolute value rather than the square.
    f = @ (pars) sum(((fun(x,pars) - y).*weights).^2) ;
    
    % Some random options for the optimization
    opts = optimset('MaxFunEvals',5000, 'MaxIter',1000, 'Display', 'off');
    
    % Do the fitting
    [fit,fval] = fminsearchbnd(f,p(1,:),p(2,:),p(3,:),opts);
    
    
end

