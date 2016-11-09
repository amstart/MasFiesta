function [Filament] = help_get_tip_intensities(Stack, Filament)
global ScanOptions
switch ScanOptions.help_get_tip_intensities.method
    case 'get_highest'
        fun = @get_highest;
    case 'get_TFI'
        fun = @get_TFI;
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
    Filament(m).Custom.Intensity=cell(1,size(Filament(m).Results,1));
    for n = 1:size(Filament(m).Results,1)
        frame = Filament(m).Results(n,1);
        missedframes=ceil(frame/framesuntilmissingframe);
        if mod(frame, framesuntilmissingframe)==1
            Filament(m).Custom.Intensity{n}=nan;
            continue
        end
        I = Stack(:,:,frame-missedframes);
        Filament(m).Custom.Intensity{n} = fun(I, Filament(m), n);
    end
    progressdlg(ifil);
    ifil=ifil+1;
end

% function [Filament] = get_TFI(Stack, Filament, Options)
function [Object] = fGetIntensity(Object)
global Stack
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