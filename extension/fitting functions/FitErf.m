function [fitresult, gof] = FitErf(x, y)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 18-Nov-2016 14:43:24


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'y0+(p0/2)*erf((x-x0)/(sqrt(2)*w0))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [1 0 -2 -0.25];
opts.Robust = 'Bisquare';
opts.StartPoint = [0.141886338627215 0.421761282626275 0.915735525189067 0];
opts.Upper = [2 20 2 0.25];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


% Plot fit with data.
% h = plot( fitresult, xData, yData );
% legend('hide');
% set(h, 'MarkerSize',30);
