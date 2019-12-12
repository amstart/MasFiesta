function [ fit_results ] = help_fit_error_function(kymodata, ScanOptions, shrinkingframes, names)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
res = 4;
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
    rf = [];
    gf = [];
    for k = 1:length(kymodata{m})
        if length(kymodata{m}{k}) ~= 1
            rf = [rf kymodata{m}{k}{1}(1)];
            gf = [gf kymodata{m}{k}{1}(2)];
        else
            rf = [rf nan];
        end
    end
    ids = ismember(rf, sf(2,:));
    for n = find(ids) %1:length(kymodata{m})
        if length(kymodata{m}{n}) == 1
            continue
        end
        I = double(kymodata{m}{n}{2});
        kymo = (nansum(I, 1)-sum(~isnan(I),1).*min(min(double(I), [], 1)));
%             try
        N_datapoints = min((extension_length+8)*res, length(kymo));
        y=kymo(1:N_datapoints);
        x=((0:length(y)-1)-extension_length*res)*(0.157/res);
        scatter(x,y,50); drawnow;
        hold on
        [fit,fval,x,y] =  ScanOptions.help_fit_error_function.fit_session(x, y);
        title([ScanOptions.File names{m} ' frame ' num2str(rf(n)) '/' num2str(n)], 'Interpreter', 'None');
        drawnow;
        prediction = convolutedExponential(x,fit);
        plot(x,prediction,'DisplayName','prediction'); drawnow;
        legend(num2str(fit,2),'Location','best'); drawnow;
        hold off
        fit_results{m}{n} = {fit,fval,questdlg('yes'),x,y,[rf(n) n]};
%             catch
%                 [names{m} ' frame ' num2str(n) '/' num2str(n-floor(n/40))];
%             end
    end
end