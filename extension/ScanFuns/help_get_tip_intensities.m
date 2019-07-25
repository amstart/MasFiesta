function [Filament] = help_get_tip_intensities(Stack, Filament)
global ScanOptions
switch ScanOptions.help_get_tip_intensities.method
    case 'get_highest'
        fun = @get_highest;
    case 'get_TFI'
        fun = @get_TFI;
    case 'get_tipandmiddleandall'
        fun = @get_tipandmiddleandall;
end
FilSelect = [Filament.Selected];
selectall = 0;
if isfield(ScanOptions.help_get_tip_intensities, 'AllFilaments') && ScanOptions.help_get_tip_intensities.AllFilaments == 1
    selectall = 1;
end
for i=1:length(FilSelect)
    if ~isempty(strfind(Filament(i).Comments, '--'))
        FilSelect(i)=0;
    end
    if Filament(i).Channel~=ScanOptions.ObjectChannel
        FilSelect(i)=0;
    end
    if Filament(i).Channel==ScanOptions.ObjectChannel && selectall
        FilSelect(i)=1;
    end
end
framesuntilmissingframe=ScanOptions.help_get_tip_intensities.framesuntilmissingframe;
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect));
ifil=1;
for m = find(FilSelect==1)
    Filament(m).Custom.CustomData=cell(1,size(Filament(m).Results,1));
    for n = 1:size(Filament(m).Results,1)
        frame = Filament(m).Results(n,1);
        missedframes=ceil(frame/framesuntilmissingframe);
        if mod(frame, framesuntilmissingframe)==1
            Filament(m).Custom.CustomData{n}=nan;
            continue
        end
        I = Stack(:,:,frame-missedframes);
        Filament(m).Custom.CustomData{n} = fun(I, Filament(m), n);
    end
    progressdlg(ifil);
    ifil=ifil+1;
end

function [sum_intensity] = get_tipandmiddleandall(I, Filament, n)
data = Filament.Data{n};
new_points = round(data(:,:)./Filament.PixelSize);
edgepoints = [new_points(1,1:2); new_points(end,1:2)];
start_i = max([min(edgepoints)-11; 1 1]);
new_points = [new_points(:, 1) - start_i(1)+1, new_points(:, 2) - start_i(2)+1];
end_i = min([max(edgepoints) + 11; 512 512]);
I = double(I(start_i(2):end_i(2), start_i(1):end_i(1)));

mask = false(size(I));
line = linept2(mask, new_points);
lines = cat(3,mask,mask,line);
lines(new_points(1:2,2),new_points(1:2,1),1) = 1;
lines(new_points(5,2),new_points(5,1),2) = 1;

in=strel('square',7);
inall=strel('square',5);
spacer=strel('square',9); %Create morphological structuring element
out=strel('square',11); %Create morphological structuring element
spacer_region = imdilate(line,spacer);
sum_intensity = nan(1,5);
for i=1:3
    if i == 1
        in_region = imdilate(lines(:,:,i),in);
    else
        in_region = imdilate(lines(:,:,i),inall);
    end
    I_in = I;
    I_in(~in_region) = nan;
    out_region = imdilate(lines(:,:,i),out);
    background = I(out_region & ~spacer_region);
    I_in = I_in - prctile(background,10);
    sum_intensity(i) = nansum(I_in(:));
    if i == 1
        I_in( ~any(in_region,2), : ) = [];  %rows
        I_in( :, ~any(in_region,1) ) = [];  %columns
        sumi = nan(size(I_in)-4);
        for j = 1:size(sumi,1)
            for k = 1:size(sumi,2)
                sumi(j,k) = nansum(nansum(I_in(j:j+4,k:k+4)));
            end
        end
        sum_intensity(4) = max(max(sumi));
        [~, maxi] = max(sumi);
        sum_intensity(5) = mean(maxi);
    end
end
%     imshow(I_in,[]);

% function [Filament] = get_TFI(Stack, Filament, Options)
function [sum_intensity] = get_TFI(I, Filament, n)
data = Filament.Data{n};
new_points = round(data./Filament.PixelSize);
edgepoints = [new_points(1,1:2); new_points(end,1:2)];
start_i = max([min(edgepoints)-9; 1 1]);
new_points = [new_points(:, 1) - start_i(1)+1, new_points(:, 2) - start_i(2)+1];
end_i = min([max(edgepoints)+9; 512 512]);
I = I(start_i(2):end_i(2), start_i(1):end_i(1));
if edgepoints(1, 1) > edgepoints(2, 1) %make it so that the plus end is on the top
    I = flipud(I);
    new_points = [flipud(new_points(:, 1)) new_points(:, 2)];
end
if edgepoints(1, 2) > edgepoints(2, 2) %make it so that the plus end is on the left
    I = fliplr(I);
    new_points = [new_points(:, 1) flipud(new_points(:, 2))];
end
mask = false(size(I));
mask = linept2(mask, fliplr(new_points));
in=strel('octagon',3);
spacer=strel('octagon',6); %Create morphological structuring element
out=strel('octagon',9); %Create morphological structuring element
in_region = imdilate(mask,in);
I_in = I;
I_in(~in_region) = 0;
I_in = I_in(8:min(17, size(I_in, 1)), 8:min(17, size(I_in, 2))); %cut off pixels which are too far from tip for sure
I_in( ~any(I_in,2), : ) = [];  %delete empty rows
I_in( :, ~any(I_in,1) ) = [];  %columns
out_region = imdilate(mask,out);
spacer_region = imdilate(mask,spacer);
background = I(out_region & ~spacer_region);
I_in = I_in - mean(background);
sum_intensity = zeros(1,7);
for x = 1:size(I_in, 1)
    for y = 1:size(I_in, 2)
        distance = sqrt((x-4)^2+(y-4)^2);
        if distance < 1.01
            sum_intensity(1) = sum_intensity(1) + double(I_in(x, y));
        elseif distance < 2.01
            sum_intensity(2) = sum_intensity(2) + double(I_in(x, y));
        elseif distance < 3.01
             sum_intensity(3) = sum_intensity(3) + double(I_in(x, y));
         elseif distance < 4.01
             sum_intensity(4) = sum_intensity(4) + double(I_in(x, y));
         elseif distance < 5.01
             sum_intensity(5) = sum_intensity(5) + double(I_in(x, y));
         elseif distance < 6.01
             sum_intensity(6) = sum_intensity(6) + double(I_in(x, y));
         elseif distance < 6.37
             sum_intensity(7) = sum_intensity(7) + double(I_in(x, y));
        end
    end
end


function [intensity_vec] = get_highest(I, Filament, n)
global ScanOptions
BackgroundOrder = sort(I(:));
Background = median(BackgroundOrder(1:10000));
BlockHalf = ScanOptions.help_get_tip_intensities.BlockHalf;
if ScanOptions.help_get_tip_intensities.MTend==1
    coords=round(double(Filament.PosStart(n,1:2)./Filament.PixelSize));
else
    coords=round(double(Filament.PosEnd(n,1:2)./Filament.PixelSize));
end
ymin = max(coords(1)-BlockHalf,1);
xmin = max(coords(2)-BlockHalf,1);
ymax = min(ymin+BlockHalf*2,512);
xmax = min(xmin+BlockHalf*2,512);
Block = I(xmin:xmax,ymin:ymax);
[~, id] = max(Block(:));
[row, col] = ind2sub(BlockHalf*2+1, id);
xminnew = max(xmin+row-BlockHalf-1,1);
yminnew = max(ymin+col-BlockHalf-1,1);
xmaxnew = min(xmax+row-BlockHalf-1,512);
ymaxnew = min(ymax+col-BlockHalf-1,512);
BlockNew = I(xminnew:xmaxnew,yminnew:ymaxnew);
SortedI = sort(BlockNew(:),'descend')-Background;
intensity_vec=SortedI(1:20);