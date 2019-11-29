function [ fit_results ] = help_fit_error_function(kymodata, ScanOptions, shrinkingframes, names)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
extension_length = ScanOptions.kymo_options.help_get_tip_kymo.ExtensionLength;
fit_results = cell(size(kymodata));
for m = 1:length(kymodata)
%     figure('units','normalized','outerposition',[0 0 1 1])
    fit_results{m} = cell(size(kymodata{m}));
    if isempty(shrinkingframes{m})
        shrinkingframes{m} = (1:length(kymodata{m}))';
    end
    for n = shrinkingframes{m}'%1:length(kymodata{m})
        kymo = (nansum(double(kymodata{m}{n}), 1)-sum(~isnan(kymodata{m}{n}),1).*min(min(double(kymodata{m}{n}), [], 1)));
        max(kymodata{m}{n}, [], 1);
        if isnan(kymo)
            fit_results{m}{n} = NaN;
        else
%             try
            N_datapoints = min(extension_length+25, length(kymo));
            y=kymo(1:N_datapoints);
            y=y-min(y);
            y=y/max(y); 
%                 y=(y-0.5);
%                 y=y*1.99;
            x=(0:length(y)-1)-extension_length;
            [fitresult, gof] =  ScanOptions.help_fit_error_function.fit_session(x, y);
%             title([ScanOptions.File names{m} ' frame ' num2str(n) '/' num2str(n-floor(n/40))], 'Interpreter', 'None');
            fit.fitresult = fitresult;
            fit.gof = gof;
            fit_results{m}{n} = fit;
%             catch
%                 [names{m} ' frame ' num2str(n) '/' num2str(n-floor(n/40))];
%             end
        end
    end
end