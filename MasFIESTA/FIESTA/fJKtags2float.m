function [f] = fJKtags2float(tags)
f=zeros(size(tags,1),1);
for i=1:size(tags,1)
    if any(tags(i,2:end))
            nums = [fliplr(tags(i,5:end)) tags(i,1)+tags(i,2).*2+tags(i,3).*4+tags(i,4).*8];
            h = dec2hex(nums);
            %Convert from float to hex
            f(i) = hexsingle2num(reshape(h,1,8)); 
            if f(i) ==  1 %for minimum compatibility with vanilla software
                f(i) = single(1.4012985e-45);
            end
    elseif tags(i,1)
        f(i) = 1; %for minimum compatibility with vanilla software
    end
end
%Convert to cell array of chars