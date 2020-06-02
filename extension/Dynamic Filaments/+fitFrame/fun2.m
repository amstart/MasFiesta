function [y] = fun2(x,pars)
    Amp = pars(1);
    % The intensity level in the microtubule
    % PSF
    sigmaerf=pars(2);
    % The value of the exponential at x=0 minus the background bg1
    bg1=pars(3);
    % The intensity level outside the microtubule
    bg2=pars(4);
    % MT end offset
    MTend = pars(5);
    
    shift = pars(6);
    
    if ~pars(7)
        sigmagauss=sigmaerf;
    else
        sigmagauss = pars(7);
    end
    % Calculation ------------------------------------
    
    gaussdist = normpdf(x,MTend,sigmagauss);
    y = ones(size(x)) * bg2 + ...
        (erf((x-MTend-shift)/(sigmaerf*sqrt(2)))+1)*bg1/2 + ...
        Amp * gaussdist/max(gaussdist);
end

