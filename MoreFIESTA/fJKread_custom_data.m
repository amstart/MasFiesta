function [ customdata_vector ] = fJKread_custom_data( customdata_cell, custom_data_name)
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
end

