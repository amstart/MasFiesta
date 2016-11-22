function [ customdata_vector ] = fJKread_custom_data(Options, varargin)
%FJKREAD_CUSTOM_DATA Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1 %used in fJKSegment
    Object = varargin{1};
    customdata_cell = Object.Custom.CustomData;
    if ~isempty(strfind(Options.eLoadCustomDataFile.print, 'fit'))
        customdata_vector = nan(size(customdata_cell, 2), 2);
        for m = 1:length(customdata_cell)
            x0 = nan(size(fit_results{1}));
            for m = 1:length(fit_results{1})
                if isstruct(fit_results{1}{m})
                    x0(m) = fit_results{1}{m}.fitresult.x0;
                end
            end
            if length(customdata_cell{m}) > 1
                background = customdata_cell{m}(end, end) * customdata_cell{m}(3, 1);
                customdata_vector(m) = customdata_cell{m}(1, 4) - background;
            else
                customdata_vector(m) = NaN;
            end
        end
    elseif ~isempty(strfind(Options.eLoadCustomDataFile.print, 'kymo'))
        customdata_vector = nan(size(customdata_cell, 2), 2);
        extension_length = Object.Custom.options_custom.help_get_tip_kymo.ExtensionLength;
        for m = 1:length(customdata_cell)
            d = customdata_cell{m};
            if isnan(d)
                continue
            end
            N_datapoints = min(extension_length+20, length(d));
            y=d(1:N_datapoints);
            customdata_vector(m, 1) = (mean(y(extension_length+1:end))-min(y))/std(y(1:extension_length-1));
            customdata_vector(m, 2) = median(y);
        end
    else
        customdata_vector = nan(size(customdata_cell, 2), 1);
        for m = 1:length(customdata_cell)
            if length(customdata_cell{m}) > 1
                background = customdata_cell{m}(end, end) * customdata_cell{m}(3, 1);
                customdata_vector(m) = customdata_cell{m}(1, 4) - background;
            else
                customdata_vector(m) = NaN;
            end
        %     customdata_vector(m) = customdata_cell{m}(1, 1);
        end
    end
else
    
end
