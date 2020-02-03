function [y] = fun2(x,pars)
    Amp = pars(1);
    % The intensity level in the microtubule
    % PSF
    PSF_width=pars(2);
    % The value of the exponential at x=0 minus the background bg1
    bg1=pars(3);
    % The intensity level outside the microtubule
    bg2=pars(4);
    % MT end offset
    MTend = pars(5);
    
    % Calculation ------------------------------------
    
    % We make a continuous xx to be able to apply the convolution, and then
    % we interpolate the x values in it.
    
    gaussdist = normpdf(x,MTend,PSF_width);
    y = ones(size(x)) * bg2 + ...
        (erf((x-MTend)/(PSF_width*sqrt(2)))+1)*bg1/2 + ...
        Amp * gaussdist/max(gaussdist);
end

