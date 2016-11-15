function [ Filament ] = help_get_tip_kymo(Stack, Filament)
%HELP_GET_TIP_KYMO Summary of this function goes here
%   Detailed explanation goes here
global ScanOptions
switch ScanOptions.help_get_tip_kymo.method
    case 'get_pixelkymo'
        fun = @get_pixelkymo;
end
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
for m = find(FilSelect==1)
    Filament(m).Custom.Intensity=cell(1,size(Filament(m).Results,1));
    if framesuntilmissingframe
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
    else
        for n = 1:size(Filament(m).Results,1)
            frame = Filament(m).Results(n,1);
            I = Stack(:,:,frame);
            Filament(m).Custom.Intensity{n} = fun(I, Filament(m), n, ScanOptions.help_get_tip_kymo.ScanSize);
        end
        progressdlg(ifil);
        ifil=ifil+1;
    end
end


function [intensity_vec] = get_pixelkymo(I, Filament, n, ScanSize)
nX=double(Filament.Data{n}(:,1)/Filament.PixelSize);
nY=double(Filament.Data{n}(:,2)/Filament.PixelSize);
d=cumsum(sqrt((nX(2:end)-nX(1:end-1)).^2 + (nY(2:end)-nY(1:end-1)).^2));
rest = 1-(d(end)+3 - floor(d(end)+3));
delta = [nX(1)-nX(2) nX(end)-nX(end-1); nY(1)-nY(2) nY(end)-nY(end-1)];
slope=[abs(delta(2,1)/delta(1,1)) abs(delta(2,2)/delta(1,2))];
addx=[sqrt((3)^2/(1+slope(1)^2)) sqrt(rest^2/(1+slope(2)^2))];
nX([1,end])=[nX(1)+sign(delta(1,1))*addx(1) nX(end)+sign(delta(1,2))*addx(2)];
nY([1,end])=[nY(1)+sign(delta(2,1))*addx(1)*slope(1) nY(end)+sign(delta(2,2))*addx(2)*slope(2)];
d=[0; cumsum(sqrt((nX(2:end)-nX(1:end-1)).^2 + (nY(2:end)-nY(1:end-1)).^2))];
dt=max(d)/round(max(d));
id=(0:round(max(d)))'*dt;
scan_length=length(id);
idx = nearestpoint(id,d);
X=zeros(scan_length,1);
Y=zeros(scan_length,1);
dis = id-d(idx);
dis(1)=0;
dis(end)=0;
X(dis==0) = nX(idx(dis==0));
Y(dis==0) = nY(idx(dis==0));
X(dis>0) = nX(idx(dis>0))+(nX(idx(dis>0)+1)-nX(idx(dis>0)))./(d(idx(dis>0)+1)-d(idx(dis>0))).*dis(dis>0);
Y(dis>0) = nY(idx(dis>0))+(nY(idx(dis>0)+1)-nY(idx(dis>0)))./(d(idx(dis>0)+1)-d(idx(dis>0))).*dis(dis>0);
X(dis<0) = nX(idx(dis<0))+(nX(idx(dis<0)-1)-nX(idx(dis<0)))./(d(idx(dis<0)-1)-d(idx(dis<0))).*dis(dis<0);
Y(dis<0) = nY(idx(dis<0))+(nY(idx(dis<0)-1)-nY(idx(dis<0)))./(d(idx(dis<0)-1)-d(idx(dis<0))).*dis(dis<0);
iX=zeros(2*ScanSize+1,scan_length);
iY=zeros(2*ScanSize+1,scan_length);
n=zeros(scan_length,3);
for i=1:length(X)
    if i==1   
        v=[X(i+1)-X(i) Y(i+1)-Y(i) 0];
        n(i,:)=[v(2) -v(1) 0]/norm(v); 
    elseif i==length(X)
        v=[X(i)-X(i-1) Y(i)-Y(i-1) 0];
        n(i,:)=[v(2) -v(1) 0]/norm(v);
    else
        v1=[X(i+1)-X(i) Y(i+1)-Y(i) 0];
        v2=-[X(i)-X(i-1) Y(i)-Y(i-1) 0];
        n(i,:)=v1/norm(v1)+v2/norm(v2); 
        if norm(n(i,:))==0
            n(i,:)=[v1(2) -v1(1) 0]/norm(v1);
        else
            n(i,:)=n(i,:)/norm(n(i,:));
        end
        z=cross(v1,n(i,:));
        if z(3)>0
            n(i,:)=-n(i,:);
        end
    end
    iX(:,i)=linspace(X(i)+ScanSize*n(i,1),X(i)-ScanSize*n(i,1),2*ScanSize+1)';
    iY(:,i)=linspace(Y(i)+ScanSize*n(i,2),Y(i)-ScanSize*n(i,2),2*ScanSize+1)';
end
intensity_vec = interp2(double(I),iX,iY,'linear');