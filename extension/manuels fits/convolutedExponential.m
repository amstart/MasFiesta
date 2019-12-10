function [y_out] = convolutedExponential(x,consts,pars)
    % Fixed parameters ------------------------------
    
    PSF_width = 0.17;
    
    % Variating parameters ------------------------
    
    % The intensity level in the microtubule
    bg1=pars(1);
    % The intensity level outside the microtubule
    bg2=consts(1);
    % The lambda of the exponential
    lambda = pars(2);
    % The value of the exponential at x=0 minus the background bg1
    Amp = pars(3);
    % MT end offset
    MTend = pars(4);
    
    % Calculation ------------------------------------
    
    % We make a continuous xx to be able to apply the convolution, and then
    % we interpolate the x values in it.
    
    xx = linspace(min(x),max(x),200);
    yy = zeros(size(xx));
    
    % The part where there is a micotubule has a background bg1+signal of
    % exponential
    x_res = xx(2)-xx(1);
    yy(xx>=MTend)= Amp*exp(-xx(xx>=MTend)/lambda)+bg1;
    
    % The part where there is no microtubule has a background of bg2
    yy(xx<MTend)=bg2;
    
    % We apply a gaussian filter with the known width, but we have to
    % convert it to distance between our xx points.
    y_conv = imgaussfilt(yy,PSF_width/x_res);
    
    y_out=interp1(xx,y_conv,x);
    
end

