function [y] = fun1(x,pars)
    Amp = pars(1);
    % The intensity level in the microtubule
    % PSF
    sigma=pars(2)/1000;
    % The value of the exponential at x=0 minus the background bg1
    bg1=pars(3);
    % The intensity level outside the microtubule
    bg2=pars(4);
    % MT end offset
    MTend = pars(5)/1000;
    %exp
    shift = pars(6)/1000;
    
    sigmaerf = pars(7)/1000;
    tau = 1/(pars(8)/1000);
    
    % Calculation ------------------------------------
    
    xend = (x - MTend)/1000;
    expdist = exp(sigma^2*tau^2/2-tau*xend).*erfc((sigma^2*tau-xend)/(sigma*sqrt(2)));
    expdist(expdist==inf) = nan;
    
    y = ones(size(x)) * bg2 + ...
        (erf((xend-shift)/(sigmaerf*sqrt(2)))+1)*bg1/2 + ...
        Amp * expdist/max(expdist);
    
end

