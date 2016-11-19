function [ customdata_vector ] = fJKread_custom_data( customdata_cell, custom_data_name, varargin)
%FJKREAD_CUSTOM_DATA Summary of this function goes here
%   Detailed explanation goes here
customdata_vector = nan(size(customdata_cell, 2), 1);
if isempty(strfind(custom_data_name, 'ymo'))
    for m = 1:length(customdata_cell)
        if length(customdata_cell{m}) > 1
            background = customdata_cell{m}(end, end) * customdata_cell{m}(3, 1);
            customdata_vector(m) = customdata_cell{m}(1, 4) - background;
        else
            customdata_vector(m) = NaN;
        end
    %     customdata_vector(m) = customdata_cell{m}(1, 1);
    end
else
    extension_length = varargin{1};
    for m = 1:length(customdata_cell)
        d = customdata_cell{m};
        if isnan(d)
            continue
        end
        N_datapoints = min(extension_length+20, length(d));
        y=d(1:N_datapoints);
%         y=(y-min(y))/(max(y)-min(y)); 
%         y=(y-0.5);
%         y=y*1.99;
%         n=length(y);
%         x=(0:n-1)-extension_length;
%         [fitresult, gof] = FitErf(x, y);
        customdata_vector(m, 1) = (mean(y(extension_length+1:end))-min(y))/std(y(1:extension_length-1));
        customdata_vector(m, 2) = median(y);
    end
end

