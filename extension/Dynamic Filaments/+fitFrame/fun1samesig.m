function [y] = fun1samesig(x,pars)
%     if pars(8)<20
%         if pars(8) < 5
%             unit = 20000;
%         else
%             unit = 10000;
%         end
%     else
%         unit = 1000;
%     end
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
    %exp
    shift = pars(7);
    
    lambda = 1/pars(6);
    
    sigmagauss=sigmaerf;
    
    % Calculation ------------------------------------
    
    xend = (x - MTend);
    
    if pars(6) == 0
        dist = normpdf(xend,0,sigmagauss);
    else
        dist = exp((sigmagauss^2*lambda^2)/2-lambda*xend).*erfc((sigmagauss^2*lambda-xend)/(sigmagauss*sqrt(2)));
        dist(dist==inf) = nan;
    end
    
    y = ones(size(x)) * bg2 + ...
        (erf((xend-shift)/(sigmaerf*sqrt(2)))+1)*bg1/2 + ...
        Amp * dist/max(dist);
    y(isnan(y)) = bg2;
%     plot(y);drawnow;
end

