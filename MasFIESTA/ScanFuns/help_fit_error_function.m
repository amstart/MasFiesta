function [ fit_results ] = help_fit_error_function(kymodata, ScanOptions)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
try
    extension_length = ScanOptions.kymo_options.help_get_tip_kymo.ExtensionLength;
    fit_results = cell(size(kymodata));
    for m = 1:length(kymodata)
        fit_results{m} = cell(size(kymodata{m}));
        m
        for n = 1:length(kymodata{m})
            kymo = max(kymodata{m}{n}, [], 1);
            if isnan(kymo)
                fit_results{m}{n} = NaN;
            else
                N_datapoints = min(extension_length+10, length(kymo));
                y=kymo(1:N_datapoints);
                y=(y-min(y))/(max(y)-min(y)); 
                y=(y-0.5);
                y=y*1.99;
                x=(0:length(y)-1)-extension_length;
                [fitresult, gof] =  ScanOptions.help_fit_error_function.fit_session(x, y);
                fit.fitresult = fitresult;
                fit.gof = gof;
                fit_results{m}{n} = fit;
            end
        end
    end
catch
    fit_results = NaN;
end