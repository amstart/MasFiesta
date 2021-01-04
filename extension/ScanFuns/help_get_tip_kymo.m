function [ out ] = help_get_tip_kymo(Stack, Filament)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
global ScanOptions
FilSelect = [Filament.Selected];
selectall = 0;
if isfield(ScanOptions.help_get_tip_kymo, 'AllFilaments') && ScanOptions.help_get_tip_kymo.AllFilaments == 1
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
framesuntilmissingframe=ScanOptions.help_get_tip_kymo.framesuntilmissingframe;
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect));
ifil=1;
out = cell(1,length(Filament));
for m = find(FilSelect==1)
    out{m} = cell(1,length(Filament(m).ForKymo));
    ForKymo = Filament(m).ForKymo;
    for n = 1:length(ForKymo)
        Data = Filament(m).Data{Filament(m).Results(:,1)==ForKymo{n}(6)};
        lastframe = -1;
        for j = 1:length(ForKymo{n})
            frame = ForKymo{n}(j);
            missedframes=ceil(frame/framesuntilmissingframe);
            currentframe = frame-missedframes;
            if currentframe > 0 && currentframe < size(Stack,3)
                I = Stack(:,:,frame-missedframes);
                PixelSize = 157;
%                 hMainGui = getappdata(0,'hMainGui');
%                 nX=hMainGui.Scan.X';
%                 nY=hMainGui.Scan.Y';
                nX=double(Data(:,1)/PixelSize);
                nY=double(Data(:,2)/PixelSize);
                out{m}{n}{j} = {[frame, currentframe], help_get_pixelkymo(I, nX, nY)};
            else
                out{m}{n}{j} = {[frame, currentframe], nan};
            end
            if currentframe == lastframe
                out{m}{n}{j-1} = {[frame-1, currentframe], nan};
            end
            lastframe = currentframe;
        end
    end
    progressdlg(ifil);
    ifil=ifil+1;
end

