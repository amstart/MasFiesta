function [tags] = fJKfloat2tags(f)
%This function converts a floating point number to its binary form.
%Hex characters
tags = zeros(size(f,1),11);
hex = '0123456789abcdef'; 
for i=1:size(f,1)
    switch f(i)
        case 0
            tags(i,:) = zeros(1,11);
        case single(1)  %for minimum compatibility with vanilla software, otherwise it would be single(1.4012985e-45)
            tags(i,:) = [1 zeros(1,10)];
        case single(1.4012985e-45)
            tags(i,:) = [0 0 0 0 0 0 0 0 8 15 3]; %for minimum compatibility with vanilla software
        case single(2.8025969e-45)
            tags(i,:) = [0 1 zeros(1,9)];
        case single(1.1210388e-44)
            tags(i,:) = [0 0 1 zeros(1,8)];
        otherwise
            %Convert from float to hex
            h = num2hex(f(i,:)); 
            %Convert to cell array of chars
            hc = num2cell(h); 
            %Convert to array of numbers
            nums =  fliplr(cellfun(@(x) find(hex == x) - 1, hc));
            flags = bitget(nums(1),1:4);
            tags(i,:) = [flags nums(2:end)];
    end
end