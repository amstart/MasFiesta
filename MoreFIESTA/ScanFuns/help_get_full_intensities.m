function [Filament] = help_get_full_intensities(Stack, Filament)
global ScanOptions
framesuntilmissingframe=ScanOptions.help_get_tip_intensities.framesuntilmissingframe;
for m = 1:length(Filament)
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
        space=strel('octagon',6); %Create morphological structuring element
        out=strel('octagon',9); %Create morphological structuring element
        try
            I_in=I(logical(imdilate(mask,in)));
        catch
            Filament(m).Custom.Intensity{n}=nan;
            continue
        end
        try
            I_space=I(logical(imdilate(mask,space)));
            I_space=I_space(I_space<median(I_space)+std(I_space));
        catch
            warning([Filament(m).Name '= space out of bounds']);
            I_space=nan;
        end
        try
            I_out=I(logical(imdilate(mask,out)));
            I_out=I_out(I_out<median(I_out)+std(I_out));
        catch
            warning([Filament(m).Name '= out out of bounds']);
            I_out=nan;
        end
        intensitymatrix = [median(I_in) mean(I_in) std(I_in) sum(I_in); median(I_space) mean(I_space) std(I_space) sum(I_space); median(I_out) mean(I_out) std(I_out) length(I_in)];
        Filament(m).Custom.Intensity{n} = intensitymatrix;
    end
end