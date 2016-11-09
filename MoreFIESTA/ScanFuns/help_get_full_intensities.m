function [Filament] = help_get_full_intensities(Stack, Filament)
global ScanOptions
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
        I = double(Stack(:,:,frame-missedframes));
        mask = zeros(512,512);
        FObPos = round(Filament(1).Data{m}(:,1:2)./ScanOptions.PixSize);
        ind = sub2ind([512,512], FObPos(:,2), FObPos(:,1));
        mask(ind) = 1;
        in=strel('octagon',3);
%         space=strel('octagon',6); %Create morphological structuring element
%         out=strel('octagon',9); %Create morphological structuring element
        try
            vals=I(logical(imdilate(mask,in)));
        catch
            Filament(m).Custom.Intensity{n}=nan;
            continue
        end
%         vals{2}=I(logical(imdilate(mask,space)));
%         vals{3}=I(logical(imdilate(mask,out)));
        BackgroundOrder = sort(I(:));
        background = BackgroundOrder(1:10000);
        intensitymatrix = [median(vals) mean(vals) std(vals) sum(vals) median(background) mean(background) std(background)];
        Filament(m).Custom.Intensity{n} = intensitymatrix;
    end
    ifil=ifil+1;
end