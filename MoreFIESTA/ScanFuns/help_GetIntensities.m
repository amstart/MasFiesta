function [Filament] = help_GetIntensities(mode, Stack, Filament)
switch mode
    case 'get_highest_tip_intensities'
        Filament = compute_highest_tip_intensities(Stack, Filament);
end

function [Filament] = compute_highest_tip_intensities(Stack, Filament)
warning('Using defaults for framesuntilmissingframe and BlockHalf, you might want to check them');
framesuntilmissingframe=40;
BlockHalf=3;
FilSelect = [Filament.Selected];
if ~sum(FilSelect)
    selectall = 1;
else
    selectall = 0;
end
for i=1:length(FilSelect)
    if ~isempty(strfind(Filament(i).Comments, '--'))
        FilSelect(i)=0;
    end
    if Filament(i).Channel>1
        FilSelect(i)=0;
    end
    if Filament(i).Channel==1 && selectall
        FilSelect(i)=1;
    end
end
warning('new setting  with ceil');
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect));
ifil=1;
for nfil = find(FilSelect==1)
    Filament(nfil).Custom.Intensity=cell(1,size(Filament(nfil).Results,1));
    for m = 1:size(Filament(nfil).Results,1)
        frame = Filament(nfil).Results(m,1);
        missedframes=ceil(frame/framesuntilmissingframe);
        if mod(frame, framesuntilmissingframe)==1
            Filament(nfil).Custom.Intensity{m}=[nan nan];
            continue
        end
        I = Stack(:,:,frame-missedframes);
        BackgroundOrder = sort(I(:));
        Background = median(BackgroundOrder(1:10000));
        for MTend=1:2
            if MTend==1
                coords=round(double(Filament(nfil).PosStart(m,1:2)./Filament(nfil).PixelSize));
            else
                coords=round(double(Filament(nfil).PosEnd(m,1:2)./Filament(nfil).PixelSize));
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
            if MTend==1
                Filament(nfil).Custom.Intensity{m}=nan(20,2);
            end
            Filament(nfil).Custom.Intensity{m}(:,MTend)=SortedI(1:20);
            if 0 %for debugging
                figure
                imshow(I)
                line(X,Y,'Color','red','LineStyle','-.');
            end
        end
    end
    progressdlg(ifil);
    ifil=ifil+1;
end