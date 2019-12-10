function [ fit_results ] = help_fit_error_function(kymodata, ScanOptions, shrinkingframes, names)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
extension_length = ScanOptions.kymo_options.help_get_tip_kymo.ExtensionLength;
fit_results = cell(size(kymodata));
for m = 1:length(kymodata)
    figure('units','normalized','outerposition',[0 0 1 1])
    fit_results{m} = cell(size(kymodata{m}));
    sf = shrinkingframes{m}';
    if any(isnan(sf))
        sf = (1:length(kymodata{m}));
        sf = [sf; sf];
    end
    for frames = sf%1:length(kymodata{m})
        n = frames(1);
        kymo = (nansum(double(kymodata{m}{n}), 1)-sum(~isnan(kymodata{m}{n}),1).*min(min(double(kymodata{m}{n}), [], 1)));
        if isnan(kymo)
            fit_results{m}{n} = NaN;
        else
%             try
            N_datapoints = min(extension_length+25, length(kymo));
            y=kymo(1:N_datapoints);
%                 y=(y-0.5);
%                 y=y*1.99;
            x=(0:length(y)-1)-extension_length;
            scatter(x,y,50); drawnow;
            hold on
            fit =  ScanOptions.help_fit_error_function.fit_session(x, y);
            title([ScanOptions.File names{m} ' frame ' num2str(frames(2)) '/' num2str(frames(2)-floor(frames(2)/40))], 'Interpreter', 'None');
            drawnow;
            hold off
%             fit.fitresult = fitresult;
%             fit.gof = gof;
            fit_results{m}{n} = {fit,questdlg('yes?'),y};
%             catch
%                 [names{m} ' frame ' num2str(n) '/' num2str(n-floor(n/40))];
%             end
        end
    end
end