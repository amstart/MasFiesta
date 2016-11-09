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
    if Filament(i).Channel>1
        FilSelect(i)=0;
    end
    if Filament(i).Channel==ScanOptions.ObjectChannel && selectall
        FilSelect(i)=1;
    end
end
framesuntilmissingframe=ScanOptions.help_get_tip_intensities.framesuntilmissingframe;
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect));
ifil=1;
for nfil = find(FilSelect==1)
    Filament(nfil).Custom.Intensity=cell(1,size(Filament(nfil).Results,1));
    for m = 1:size(Filament(nfil).Results,1)
        frame = Filament(nfil).Results(m,1);
        missedframes=ceil(frame/framesuntilmissingframe);
        if mod(frame, framesuntilmissingframe)==1
            Filament(nfil).Custom.Intensity{m}=nan;
            continue
        end
        I = Stack(:,:,frame-missedframes);
        Filament(nfil).Custom.Intensity{m} = fun(I, Filament(nfil), m);
    end
    progressdlg(ifil);
    ifil=ifil+1;
end

% function [Filament] = get_TFI(Stack, Filament, Options)



function [intensity_vec] = get_highest(I, Filament, m)
global ScanOptions
BackgroundOrder = sort(I(:));
Background = median(BackgroundOrder(1:10000));
BlockHalf = ScanOptions.help_get_tip_intensities.BlockHalf;
if ScanOptions.help_get_tip_intensities.MTend==1
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