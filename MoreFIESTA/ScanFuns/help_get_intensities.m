function [Object] = help_get_intensities(Stack, Object)
global ScanOptions
switch ScanOptions.help_get_intensities.method
    case 'get_at_tip_highest'
        fun = @get_at_tip_highest;
    case 'get_TFI'
        fun = @get_TFI;
end
FilSelect = [Object.Selected];
selectall = 0;
if isfield(ScanOptions.help_get_intensities, 'AllFilaments') && ScanOptions.help_get_intensities.AllFilaments == 1
    selectall = 1;
end
for i=1:length(FilSelect)
    if ~isempty(strfind(Object(i).Comments, '--'))
        FilSelect(i)=0;
    end
    if Object(i).Channel>1
        FilSelect(i)=0;
    end
    if Object(i).Channel==ScanOptions.ObjectChannel && selectall
        FilSelect(i)=1;
    end
end
framesuntilmissingframe=ScanOptions.help_get_intensities.framesuntilmissingframe;
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect));
ifil=1;
for m = find(FilSelect==1)
    Object(m).Custom.Intensity=cell(1,size(Object(m).Results,1));
    for n = 1:size(Object(m).Results,1)
        frame = Object(m).Results(n,1);
        missedframes=ceil(frame/framesuntilmissingframe);
        if mod(frame, framesuntilmissingframe)==1
            Object(m).Custom.Intensity{n}=nan;
            continue
        end
        I = Stack(:,:,frame-missedframes);
        Object(m).Custom.Intensity{n} = fun(I, Object(m), n);
    end
    progressdlg(ifil);
    ifil=ifil+1;
end

function [intensity_vec] = get_TFI(I, Filament, m)
ang = 0:pi/100:2*pi;
IStack = Stack{2};
for n = 1:length(Object)
    xStack = size(IStack,2);
    yStack = size(IStack,1);
    for m = 1:size(Object(n).Results,1)
        I = IStack(:,:,Object(n).Results(m,1));
        area = false(yStack,xStack ,size(Object(n).Data{m},1));
        for k = 1:size(Object(n).Data{m},1) %this is the problem with this script: it takes datapoints, not paths
            %if the widths of the datapoints are not equal (i.e. the filaments have varying brightness), you might get
            %surprising results
            x = Object(n).Data{m}(k,1)+cos(ang)*Object(n).Data{m}(k,4)/(2*sqrt(2*log(2)))*4;
            y = Object(n).Data{m}(k,2)+sin(ang)*Object(n).Data{m}(k,4)/(2*sqrt(2*log(2)))*4;
            area(:,:,k) = roipoly(I,x/Object(n).PixelSize,y/Object(n).PixelSize);
        end
        Object(n).Intensity(m)=sum(I(max(area, [], 3)));  %das musst du nochmal ueberpruefen, hab das eben geschrieben. das area zeug ist vom originalen skript
    end
end


function [intensity_vec] = get_at_tip_highest(I, Filament, m)
global ScanOptions
BackgroundOrder = sort(I(:));
Background = median(BackgroundOrder(1:10000));
BlockHalf = ScanOptions.help_get_intensities.BlockHalf;
if ScanOptions.help_get_intensities.MTend==1
    coords=round(double(Filament.PosStart(m,1:2)./Filament.PixelSize));
else
    coords=round(double(Filament.PosEnd(m,1:2)./Filament.PixelSize));
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