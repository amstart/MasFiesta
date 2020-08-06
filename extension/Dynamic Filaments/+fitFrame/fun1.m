function [y] = fun1(x,pars)
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
    shift = pars(6);
    
    tau = 1/pars(8);
    
    if ~pars(7)
        sigmagauss=sigmaerf;
    else
        sigmagauss = pars(7);
    end
    
    % Calculation ------------------------------------
    
    xend = (x - MTend);
    expdist = exp((sigmagauss^2*tau^2)/2-tau*xend).*erfc((sigmagauss^2*tau-xend)/(sigmagauss*sqrt(2)));
    expdist(expdist==inf) = nan;
    
    y = ones(size(x)) * bg2 + ...
        (erf((xend-shift)/(sigmaerf*sqrt(2)))+1)*bg1/2 + ...
        Amp * expdist/max(expdist);
    y(isnan(y)) = bg2;
%     plot(y);drawnow;
end

