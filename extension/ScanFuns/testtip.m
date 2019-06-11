I = Stack{1,1}{1};
data = Filament.Data{n};
new_points = round(data(1:6,:)./Filament.PixelSize);
edgepoints = [new_points(1,1:2); new_points(end,1:2)];
start_i = max([min(edgepoints)-9; 1 1]);
new_points = [new_points(:, 1) - start_i(1)+1, new_points(:, 2) - start_i(2)+1];
end_i = min([max(edgepoints) + 9; 512 512]);
I = I(start_i(2):end_i(2), start_i(1):end_i(1));

mask = false(size(I));
line = linept2(mask, new_points);
lines = cat(3,mask,mask);
lines(new_points(1,2),new_points(1,1),1) = 1;
lines(new_points(6,2),new_points(6,1),2) = 1;


in=strel('rectangle',[5 5]);
spacer=strel('octagon',6); %Create morphological structuring element
out=strel('octagon',9); %Create morphological structuring element
spacer_region = imdilate(line,spacer);
sum_intensity = nan(1,2);
for i=1:2
    figure
    in_region = imdilate(lines(:,:,i),in);
    I_in = I;
    I_in(~in_region) = 0;
    out_region = imdilate(lines(:,:,i),out);
    background = I(out_region & ~spacer_region);
    I_in = I_in - prctile(background,10);
    sum_intensity(i) = sum(sum(double(I_in)));
    imshow(I_in,[]);
end