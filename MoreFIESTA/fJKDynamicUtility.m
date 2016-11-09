function fJKDynamicUtility(func,varargin)
%FJKUTILITY Summary of this function goes here
%   Detailed explanation goes here
switch (func)
    case 'Create'
        Create;
    case 'GetIntensities'
        GetIntensities;
    case 'ApplyType'
        ApplyType;
    case 'JKGetIntensity'
        JKGetIntensity(varargin{:});
    case 'JKInterpolateTrack'
        JKInterpolateTrack(varargin{:});
    case 'Match'
        Match(varargin{:});
    case 'FindPlusEnd'
        FindPlusEnd(varargin{:});
    case 'SetIntensityPerMAP'
        SetIntensityPerMAP;
end

function Create
fJKDynamicUtility.fig = dialog('Name','Dynamic Filament Utility','Position',[30 30 500 700],'toolbar','none','menu','none', 'WindowStyle', 'normal');
fJKDynamicUtility.tMenu = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.1 0.7 0.9 0.2],'Style','text', 'FontSize', 12,'HorizontalAlignment','left',...
    'String','First rename your filaments, then apply drift correction, apply the color map and color-align subsequently. Find these functions in fJKDynamicUtility.m'); 
fJKDynamicUtility.bMatch = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.7 0.6 0.07],'FontSize',13,...
                             'String','Match Filaments','HorizontalAlignment','center', 'Callback', 'fJKDynamicUtility(''Match'');');
fJKDynamicUtility.eType = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.3 0.6 0.4 0.07],'Enable','on','FontSize',8,...
                             'String','SingleA/OLA/Single/OL','Style','edit','HorizontalAlignment','center');  
fJKDynamicUtility.bApplyType = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.5 0.6 0.07],'FontSize',13,...
                             'String','Apply Type','HorizontalAlignment','center', 'Callback', 'fJKDynamicUtility(''ApplyType'');', 'UserData', 1);
fJKDynamicUtility.bFindPlusEnd = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.4 0.6 0.07],'FontSize',13,...
                             'String','Find Plus Ends','HorizontalAlignment','center', 'Callback', 'fJKDynamicUtility(''FindPlusEnd'');');
fJKDynamicUtility.bInterpolateTracks = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.3 0.6 0.07],'FontSize',13,...
                             'String','Interpolate Tracks','HorizontalAlignment','center', 'Callback', 'answer=str2double(inputdlg(''How many frames per framein channel 1?'', ''?'',1, {''40''})); fJKDynamicUtility(''JKInterpolateTrack'', answer, 0);');
fJKDynamicUtility.bGetIntensities = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.2 0.6 0.07],'FontSize',13,...
                             'String','Get Intensities','HorizontalAlignment','center', 'Callback', 'fJKDynamicUtility(''GetIntensities'');', 'TooltipString', 'If not done yet, corrects the Stack first before getting the intensities.');
fJKDynamicUtility.bSetIntensityPerMAP = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.12 0.6 0.05],'FontSize',13,...
                             'String','Set Intensity Per MAP','HorizontalAlignment','center', 'Callback', 'fJKDynamicUtility(''SetIntensityPerMAP'');', 'TooltipString', 'Sets Filament.Custom.IntensityPerMAP.');
fJKDynamicUtility.bDynamicFilamentsGUI = uicontrol('Parent',fJKDynamicUtility.fig,'Units','normalized','Position',[0.2 0.01 0.6 0.07],'FontSize',13,...
                             'String','Open Dynamic Filaments GUI','HorizontalAlignment','center', 'Callback', @fJKDynamicFilamentsGui, 'TooltipString', 'Calls fJKDynamicFilamentsGui.m');
setappdata(0,'fJKDynamicUtility',fJKDynamicUtility);
                  
function SetIntensityPerMAP
global Filament
value = inputdlg('How much intensity per MAP?', '?',1, {'238'});
for i=1:length(Filament)
    if ~isempty(Filament(i).Custom)
        Filament(i).Custom.IntensityPerMAP=str2double(value);
    end
end

function ApplyType
fJKDynamicUtility = getappdata(0,'fJKDynamicUtility');
fShared('BackUp',getappdata(0,'hMainGui'));
newType = get(fJKDynamicUtility.eType, 'String');
global Filament
for i=1:length(Filament)
    typecomment = strfind(Filament(i).Comments, 'type:');
    if ~isempty(strfind(Filament(i).Comments, 'ref')) && isempty(typecomment)
        Filament(i).Comments=[Filament(i).Comments ' type:' newType];
    elseif ~isempty(typecomment)
        restcomment=Filament(i).Comments(typecomment+5:end);
        space=strfind(restcomment(1:end),' ');
        if isempty(space)
            space=length(restcomment(1:end))+1;
        end
        Filament(i).Comments=strrep(Filament(i).Comments, ['type:' restcomment(1:space(1)-1)], ['type:' newType]);
    end
end

function GetIntensities
global Stack
global Filament
global ScanOptions
hMainGui=getappdata(0,'hMainGui');
if strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'off')
    answer = questdlg('Want to continue and correct the stack?', 'Warning', 'Yes','No','Yes' );
    if strcmp(answer, 'No')
        return
    end
    Drift=getappdata(hMainGui.fig,'Drift');
    OffSetMap=getappdata(hMainGui.fig,'OffsetMap');
    if isempty(Drift) || isempty(OffSetMap) 
        msgbox('Error: Either Drift or Offsetmap not loaded.');
        return
    end
    fMenuView('CorrectStack');
end
ScanOptions.help_get_tip_intensities.BlockHalf = 3; %only needed for mode "get_highest"
ScanOptions.help_get_tip_intensities.framesuntilmissingframe = 40; %set to number higher than number of frames if you have the same number of frames for the channels
ScanOptions.help_get_tip_intensities.MTend = 1; %1 = PosStart, 2 = PosEnd
ScanOptions.help_get_tip_intensities.method = 'get_highest';
ScanOptions.help_get_tip_intensities.AllFilaments = 1;
ScanOptions.Channel = 2;
fShared('BackUp',hMainGui);
[Filament] = help_get_tip_intensities(Stack{ScanOptions.Channel}, Filament);
                                 

function JKInterpolateTrack(copynumber,idx)
global TimeInfo;
global Filament;
hMainGui=getappdata(0,'hMainGui');
if isempty(copynumber)
    return
end
fShared('BackUp',hMainGui);
if idx
    toInterpolate=idx;
else
    toInterpolate=find([Filament.Channel]>1);
end
for m=toInterpolate
    Object=Filament(m);
    frames=1:size(Object.Results,1);
    Tags = fJKfloat2tags(Object.Results(:,end));
    if ~any(Tags(:, 2))
        Results=[Object.Results(:,1:end-1) Object.PosStart Object.PosCenter Object.PosEnd];
        for idx=fliplr(frames)
            if idx<size(Results,1);
                tmp=zeros(copynumber+1,18);
                for n=1:18
                    tmp(:,n)=linspace(Results(idx,n),Results(idx+1,n),copynumber+1);
                end
                Results=[Results(1:idx-1,:); tmp(1:end-1,:); Results(idx+1:end,:)];
                Tags=[Tags(1:idx,:); repmat([0 1 zeros(1,9)], copynumber-1, 1); Tags(idx+1:end,:)];
            end   
        end
        Results(:,1)=round((Results(:,1)-1)*copynumber+1);
        Tags = fJKtags2float(Tags);
        Results(:,2)=(TimeInfo{1}(Results(:,1))-TimeInfo{1}(1))./1000;
        Object.Results=[Results(:,1:9) Tags];
        Object.PosStart=Results(:,10:12);
        Object.PosCenter=Results(:,13:15);   
        Object.PosEnd=Results(:,16:18);  
    end
    Filament(m)=Object;
end

function FindPlusEnd
global Filament
fShared('BackUp',getappdata(0,'hMainGui'));
if ~isempty(Filament)
    idx=find([Filament.Channel]==1);
    for n=idx
        Object=Filament(n);
        alltags = fJKfloat2tags(Filament(n).Results(:,end));
        startpos=double(Object.PosStart(alltags(:,6)~=9,:));
        endpos=double(Object.PosEnd(alltags(:,9)~=9,:));
        relativestart=fDis(startpos);
        relativeend=fDis(endpos);
        dynstart=sum(diff(smooth(relativestart, 'rlowess')));
        dynend=sum(diff(smooth(relativeend, 'rlowess')));
        if dynend>dynstart
            for i = 1:size(endpos,1)
                Object.Data{i}=flipud(Object.Data{i});
            end
            Object.PosStart=endpos;
            Object.PosEnd=startpos;   
        end
        Filament(n)=Object;
        refcomment=strfind(Object.Comments,'ref:');
        if ~isempty(refcomment)
        restcomment=Object.Comments(refcomment+4:end);
            if ~isempty(strfind(restcomment,'-'))
                dash=strfind(restcomment,'-');
                refname=restcomment(1:dash(1)-1);
                refindex=find(arrayfun(@(x) strcmp(x.Name, refname), Filament)==1);
                Object=Filament(refindex);
                if norm([Object.PosEnd(1,1)-Filament(n).PosEnd(1,1) Object.PosEnd(1,2)-Filament(n).PosEnd(1,2)])>norm([Object.PosStart(1,1)-Filament(n).PosEnd(1,1) Object.PosStart(1,2)-Filament(n).PosEnd(1,2)])
                    endposref=Object.PosEnd;
                    for i = 1:length(Object.Data)
                        Object.Data{i}=flipud(Object.Data{i});
                    end
                    Object.PosEnd=Object.PosStart;   
                    Object.PosStart=endposref;
                end
                Filament(refindex)=Object;
            end
        end
    end
end

function Match
global Filament;
fShared('BackUp',getappdata(0,'hMainGui'));
if ~isempty(Filament)
    FilOtherChannel=Filament([Filament.Channel]~=1);
    centervec=zeros(length(FilOtherChannel),3);
    for i=1:length(FilOtherChannel)
        centervec(i,:)=FilOtherChannel(i).PosCenter(1,:);
    end
    for i=1:length(Filament)
        if Filament(i).Channel==1
            refcommentstart = strfind(Filament(i).Comments, 'ref:');
            if ~isempty(refcommentstart)
                restcomment = Filament(i).Comments(refcommentstart:end);
                dash=strfind(restcomment,'-');
                refcomment=restcomment(1:dash(1));
                Filament(i).Comments = strrep(Filament(i).Comments, refcomment, '');
                Filament(i).Comments = strrep(Filament(i).Comments, '  ', ' ');
            end
            disvec = fDis([Filament(i).PosCenter(1,:); centervec]);
            [~, n] = min(disvec(2:end,:));
            Filament(i).Comments = [Filament(i).Comments ' ref:' FilOtherChannel(n).Name '-'];
        end
    end
end

function JKGetIntensityold
global Filament
global Stack
hMainGui=getappdata(0,'hMainGui');
FilSelect = zeros(length(Filament),1);
for i=1:length(FilSelect)
    if Filament(i).Selected
        FilSelect(i)=1;
    end
    if ~isempty(strfind(Filament(i).Comments, '--'))
        FilSelect(i)=0;
    end
    if Filament(i).Channel>1
        FilSelect(i)=0;
    end
end
warning('new setting  with ceil');
channel=2;
divisor=40;
ScanSize=5;
IStack = Stack{channel};
progressdlg('String','Extracting Intensities','Min',0,'Max',sum(FilSelect),'Parent',hMainGui.fig);
ifil=1;
for nfil = find(FilSelect==1)'
    Filament(nfil).Custom.Intensity=cell(1,size(Filament(nfil).Results,1));
    for m = 1:size(Filament(nfil).Results,1)
        frame = Filament(nfil).Results(m,1);
        missedframes=ceil(frame/divisor);
        if mod(frame, divisor)==1
            Filament(nfil).Custom.Intensity{m}=[nan nan];
            continue
        end
        I = IStack(:,:,frame-missedframes);
        for MTend=1:2
            if MTend==1
                nX=double(Filament(nfil).Data{m}(:,1)/Filament(nfil).PixelSize);
                nY=double(Filament(nfil).Data{m}(:,2)/Filament(nfil).PixelSize);
            else
                nX=flipud(double(Filament(nfil).Data{m}(:,1)/Filament(nfil).PixelSize));
                nY=flipud(double(Filament(nfil).Data{m}(:,2)/Filament(nfil).PixelSize));
            end
            d=cumsum(sqrt((nX(2:end)-nX(1:end-1)).^2 + (nY(2:end)-nY(1:end-1)).^2));
            rest = 1-(d(end)+0.5 - floor(d(end)+0.5));
            delta = [nX(1)-nX(2) nX(end)-nX(end-1); nY(1)-nY(2) nY(end)-nY(end-1)];
            slope=[abs(delta(2,1)/delta(1,1)) abs(delta(2,2)/delta(1,2))];
            addx=[sqrt((0.5)^2/(1+slope(1)^2)) sqrt(rest^2/(1+slope(2)^2))];
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
            Z = interp2(double(I),iX,iY,'linear');
            if MTend==1
                Filament(nfil).Custom.Intensity{m}=nan(size(Z,2),2);
            end
            Filament(nfil).Custom.Intensity{m}(:,MTend)=nansum(Z,1)';
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