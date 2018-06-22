function [Filament, Molecule] = fConnectObjects(Objects, Config, JobNr, Stack)
%FCONNECTTRACKS Summary of this function goes here
%   Detailed explanation goes here
% try
    [MolTrack,FilTrack,abort]=fFeatureConnect(Objects,Config,JobNr);     
% catch ME
%     save(fData,'ME','-append');
%     return;
% end
if abort==1
    return
end
Molecule=[];
Filament=[];
Molecule=fDefStructure(Molecule,'Molecule');
Filament=fDefStructure(Filament,'Filament');
nMolTrack=length(MolTrack);

nChannel = Config.TrackChannel;
if length(Config.TformChannel)==1
    T = Config.TformChannel{1};
else
    T = Config.TformChannel{nChannel};
end

T(3,3) = 1;

for n = 1:nMolTrack
    nData=size(MolTrack{n},1);
    Molecule(n).Name = ['Molecule ' num2str(n)];
    Molecule(n).File = Config.StackName;
    Molecule(n).Comments = '';
    Molecule(n).Selected = 0;
    Molecule(n).Visible = true;    
    Molecule(n).Drift = 0;            
    Molecule(n).PixelSize = Config.PixSize;  
    Molecule(n).Channel = nChannel;
    Molecule(n).TformMat = T;
    Molecule(n).Color = [0 0 1];
    for j = 1:nData
        f = MolTrack{n}(j,1);
        m = MolTrack{n}(j,2);
        Molecule(n).Results(j,1) = single(f);
        Molecule(n).Results(j,2) = Objects{f}.time;
        Molecule(n).Results(j,3) = Objects{f}.center_x(m);
        Molecule(n).Results(j,4) = Objects{f}.center_y(m);
        Molecule(n).Results(j,5) = NaN;
        Molecule(n).Results(j,7) = Objects{f}.width(1,m);
        Molecule(n).Results(j,8) = Objects{f}.height(1,m);                
        Molecule(n).Results(j,9) = single(sqrt((Objects{f}.com_x(2,m))^2+(Objects{f}.com_y(2,m))^2));                        
        if size(Objects{f}.data{m},2)==1
            Molecule(n).Results(j,9:10) = Objects{f}.data{m}';                
            Molecule(n).Results(j,11) = single(mod(Objects{f}.orientation(1,m),2*pi));                
            Molecule(n).Type = 'stretched';
            Molecule(n).Results(j,12) = 0; 
        elseif size(Objects{f}.data{m},2)==3
            Molecule(n).Results(j,9:11) = Objects{f}.data{m}(1,:);                
            Molecule(n).Type = 'ring1';
            Molecule(n).Results(j,12) = 0; 
        else
            Molecule(n).Type = 'symmetric';
            Molecule(n).Results(j,10) = 0; 
        end
        if Config.OnlyTrack.IncludeData == 1
            Molecule(n).TrackingResults{j} = Objects{f}.points{m};
        else
            Molecule(n).TrackingResults{j} = [];
        end       

    end
    Molecule(n).Results(:,6) = fDis(Molecule(n).Results(:,3:5));
end
if ~isempty(Stack)
    sStack=size(Stack{1});
end
nFilTrack=length(FilTrack);
for n = nFilTrack:-1:1
    nData=size(FilTrack{n},1);
    Filament(n).Name = ['Filament ' num2str(n)];
    Filament(n).File = Config.StackName;
    Filament(n).Comments = '';
    Filament(n).Selected=0;
    Filament(n).Visible=true;    
    Filament(n).Drift=0;    
    Filament(n).PixelSize = Config.PixSize;   
    Filament(n).Channel = nChannel;
    Filament(n).TformMat = T;
    Filament(n).Color=[0 0 1];
    for j=1:nData
        f = FilTrack{n}(j,1);
        m = FilTrack{n}(j,2);
        Filament(n).Results(j,1) = single(f);
        Filament(n).Results(j,2) = Objects{f}.time;
        Filament(n).Results(j,3) = Objects{f}.center_x(m);
        Filament(n).Results(j,4) = Objects{f}.center_y(m);
        Filament(n).Results(j,5) = NaN;
        Filament(n).Results(j,7) = Objects{f}.length(1,m);
        Filament(n).Results(j,8) = Objects{f}.height(1,m);                
        Filament(n).Results(j,9) = single(mod(Objects{f}.orientation(1,m),2*pi));
        Filament(n).Results(j,10) = 0;
        Filament(n).Data{j} = [Objects{f}.data{m}(:,1:2) ones(size(Objects{f}.data{m},1),1)*NaN Objects{f}.data{m}(:,3:end)];
        Filament(n).PosCenter(j,1:3)=[Filament(n).Results(j,3:4) NaN];  
        if Config.OnlyTrack.IncludeData == 1
            Filament(n).TrackingResults{j} = Objects{f}.points{m};
        else
            Filament(n).TrackingResults{j} =[];
        end       
    end

    Filament(n) = fAlignFilament(Filament(n),Config);

    if Config.ConnectFil.DisregardEdge && ~isempty(Stack)                                          
        xv = [5 5 sStack(2)-4 sStack(2)-4]*Config.PixSize;
        yv = [5 sStack(1)-4 sStack(1)-4 5]*Config.PixSize;            
        X=Filament(n).PosStart(:,1);
        Y=Filament(n).PosStart(:,2);
        IN = inpolygon(X,Y,xv,yv);
        Filament(n).Results(~IN,:)=[];            
        Filament(n).PosStart(~IN,:)=[];
        Filament(n).PosCenter(~IN,:)=[];
        Filament(n).PosEnd(~IN,:)=[];
        Filament(n).Data(~IN)=[];            
        X=Filament(n).PosEnd(:,1);
        Y=Filament(n).PosEnd(:,2);
        IN = inpolygon(X,Y,xv,yv);
        Filament(n).Results(~IN,:)=[];
        Filament(n).PosStart(~IN,:)=[];
        Filament(n).PosCenter(~IN,:)=[];
        Filament(n).PosEnd(~IN,:)=[]; 
        Filament(n).Data(~IN)=[];
        if isempty(Filament(n).Results)
            Filament(n)=[];
        else
            Filament(n).Results(:,6) = fDis(Filament(n).Results(:,3:5));
        end
    end
end
