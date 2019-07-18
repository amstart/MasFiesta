tic
I = Stack{1,1}{1};
data = Filament.Data{n}(:,1:2);
new_points = round(data(:,:)./Filament.PixelSize);
new_points(:,1) = new_points(:,1);
edgepoints = [new_points(1,:); new_points(end,1:2)];
start_i = max([min(edgepoints)-15; 1 1]);
new_points = [new_points(:, 1) - start_i(1)+1, new_points(:, 2) - start_i(2)+1];
end_i = min([max(edgepoints) + 15; 512 512]);
I = double(I(start_i(2):end_i(2), start_i(1):end_i(1)));

I = double(I);

% mask = false(size(I));
% mask(new_points(:,2), new_points(:,1)) = 1;
% 
% se=strel('rectangle',[3 3]); 
% im_er = imdilate(mask,se);
% line = imerode(im_er,se);

mask = false(size(I));
line = linept2(mask, new_points);

in=strel('rectangle',[5 5]);
spacer=strel('octagon',6); %Create morphological structuring element
out=strel('octagon',9); %Create morphological structuring element
spacer_region = imdilate(line,spacer);
in_region = imdilate(line,in);
I_in = I;
I_in(~in_region) = nan;
out_region = imdilate(line,out);
background = I(out_region & ~spacer_region);
I_in = I_in - prctile(background,10);
sum_intensity = [nansum(nansum(I_in)) nanmean(I_in(:))]
toc
figure
imshow(I_in,[])