function fRightPanel(func,varargin)
switch func
    case 'DeleteHandles'
        DeleteHandles;
    case 'UpdateMeasure'
        UpdateMeasure(varargin{1});
    case 'NewScan'
        NewScan(varargin{1});    
    case 'CreateFilamentScan'
        CreateFilamentScan(varargin{1});        
    case 'NewKymoGraph'
        NewKymoGraph(varargin{1});                
    case 'KymoFrames'
        KymoFrames(varargin{1});                        
    case 'UpdateLineScan'
        UpdateLineScan(varargin{1});                
    case 'DataPanel'
        DataPanel(varargin{1});        
    case 'ToolsPanel'
        ToolsPanel(varargin{1});
    case 'QueuePanel'
        QueuePanel(varargin{1});
    case 'DataMoleculesPanel'
        DataMoleculesPanel(varargin{1});     
    case 'DataFilamentsPanel'
        DataFilamentsPanel(varargin{1});          
    case 'ToolsMeasurePanel'
        ToolsMeasurePanel(varargin{1});     
    case 'ToolsScanPanel'
        ToolsScanPanel(varargin{1});   
    case 'QueueServerPanel'
        QueueServerPanel(varargin{1});     
    case 'QueueLocalPanel'
        QueueLocalPanel(varargin{1});   
    case 'ToggleTool'
        ToggleTool(varargin{1});
    case 'AllToolsOff'
        AllToolsOff(varargin{1});
    case 'MeasureTable'
        MeasureTable(varargin{1});
    case 'ScanSize'
        ScanSize(varargin{1});
    case 'ShowKymoGraph'
        ShowKymoGraph(varargin{1});
   case 'DeleteScan'
       DeleteScan(varargin{:});      
    case 'UpdateList'
        UpdateList(varargin{:});
    case 'ListSlider'
        ListSlider(varargin{1});
    case 'ListButton'
        ListButton(varargin{1},varargin{2});
    case 'ListVisible'
        ListVisible(varargin{1},varargin{2});
    case 'QueueCheck'
        QueueCheck(varargin{1});
    case 'UpdateQueue'
        UpdateQueue(varargin{1});
    case 'QueueSlider'
        QueueSlider;        
    case 'ShowAllFil'
        ShowAllFil;        
    case 'SubtractDrift'
        SubtractDrift(varargin{1});
    case 'DeleteQueue'
        DeleteQueue(varargin{1});
    case 'ExportMeasure'
        ExportMeasure(varargin{1});        
    case 'ExportScan'
        ExportScan(varargin{1});           
    case 'ExportKymo'
        ExportKymo(varargin{1});          
    case 'RefreshServerQueue'
        RefreshServerQueue(varargin{1});
    case 'CheckDrift'
        CheckDrift(varargin{1});      
    case 'CorrectKymoIndex'
        CorrectKymoIndex(varargin{1});      
    case 'IgnoreObjects'   
        IgnoreObjects(varargin{1},varargin{2});
    case 'RenameObject'   
        RenameObject(varargin{1},varargin{2});        
    case 'LoadQueue'   
        LoadQueue;        
    case 'SaveQueue'   
        SaveQueue;                
    case 'UpdateKymoTracks'   
        UpdateKymoTracks(varargin{1});                        
    case 'CheckConfig'   
        CheckConfig;                 
end

function CheckConfig
fConfigGui('Create');
fShared('ReturnFocus');

function ExportKymo(hMainGui)
if isfield(hMainGui, 'KymoName') %JochenK
   KymoName=[fShared('GetSaveDir') hMainGui.KymoName];
else
   KymoName=fShared('GetSaveDir');
end
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','Matlab file';'*.*','Screenshot and tif';'*.tif','TIFF-File (*.tif)';'*.png','Screenshot (*.png)'},'Save FIESTA Kymograph',KymoName); 
if FileName~=0
    fShared('SetSaveDir',PathName);
    FileName = strrep(FileName, '.png', '');
    FileName = strrep(FileName, '.tif', '');
    file = [PathName FileName];
    Image=hMainGui.KymoImage;
    measuredLines = hMainGui.Measure;
    if FilterIndex==1
        save(file,'Image','measuredLines');
        FilterIndex = 2;
        file = file(1:end-4);
    end
    if FilterIndex==2||FilterIndex==3
        imwrite(uint16(Image(:,:,1)),[file '.tif'],'Compression','none');  
        if size(Image,3)>1
            for c=2:size(Image,3)
                imwrite(uint16(Image(:,:,c)),[file '.tif'],'Compression','none','WriteMode','append');  
            end
        end
    end
    if FilterIndex==2||FilterIndex==4
        imageData = screencapture(hMainGui.fig);
        imwrite(imageData,[file '.png']);
    end
    if get(hMainGui.RightPanel.pTools.cKymoLocation,'Value')==1
        if ~exist([PathName 'locations'], 'dir')
          mkdir([PathName 'locations']);
        end
        saveas(hMainGui.MidPanel.aView, [PathName 'locations' filesep FileName '.jpg'], 'jpg') %Save figure;
    end
end
fShared('ReturnFocus');

function ExportScan(hMainGui)
global Config;
if isfield(hMainGui, 'KymoName') %JochenK
   KymoName=[fShared('GetSaveDir') hMainGui.KymoName];
else
   KymoName=fShared('GetSaveDir');
end
[FileName, PathName, FilterIndex] = uiputfile({'*.csv','csv-File (*.csv)';'*.txt','TXT-File (*.txt)';'*.jpg','JPG-File (*.jpg)'},'Save scan',KymoName);
if PathName~=0
    fShared('SetSaveDir',PathName);
    set(hMainGui.fig,'Pointer','watch');   
    if FilterIndex==3
        if isempty(strfind(FileName,'.jpg'))
            file=sprintf('%s/%s.jpg',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    end
    if FilterIndex==2
        if isempty(strfind(FileName,'.txt'))
            file=sprintf('%s/%s.txt',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    end
    if FilterIndex==1
        if isempty(strfind(FileName,'.csv'))
            file=sprintf('%s/%s.csv',PathName,FileName);
        else
            file=sprintf('%s/%s',PathName,FileName);
        end
    end
    if hMainGui.Values.FrameIdx<1
        f=round(get(hMainGui.MidPanel.sFrame,'Value'));
    else
        f=hMainGui.Values.FrameIdx;
    end
    I = hMainGui.Scan.I;
    D = hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000;
    if FilterIndex==3
        h=figure('PaperUnits','centimeter','Visible','off','PaperType','A4','PaperPositionMode','manual','PaperPosition',[0 0 29.7 21]);
        plot(D,I,'b-');
        xlabel('Intensity vs. Distance in um');
        print(h,file,'-djpeg','-r600');
        close(h);
    elseif FilterIndex==2
        fh=fopen(file,'w');
        fprintf(fh,'%s - Frame: %d\n',Config.StackName,f);
        fprintf(fh,'Distance[um]\tIntensity[counts]\n');
        for j=1:length(D)
            fprintf(fh,'%f\t%f\n',D(j),I(1,j));
        end
        fclose(fh);
    elseif FilterIndex==1
        csvwrite(file, [D I']);
    end
    scan = hMainGui.Scan;
    save([file '.mat'], 'scan');
    if get(hMainGui.RightPanel.pTools.cKymoLocation,'Value')==1
        if ~exist([PathName 'locations'], 'dir')
          mkdir([PathName 'locations']);
        end
        saveas(hMainGui.MidPanel.aView, [PathName 'locations' filesep FileName '.jpg'], 'jpg') %Save figure;
    end
    setappdata(0,'hMainGui',hMainGui);
    set(hMainGui.fig,'Pointer','arrow');       
end        
fShared('ReturnFocus');

function ExportMeasure(hMainGui)
[FileName, PathName] = uiputfile({'*.txt','TXT-File (*.txt)'},'Save FIESTA Measurements',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];    
    if isempty(findstr('.txt',file))
        file = [file '.txt'];
    end       
    str{1}='';
    if get(hMainGui.RightPanel.pTools.cLengthArea,'Value')==1
        str{1}=sprintf(['%sLength/Area [' char(956) 'm/' char(956) 'm' char(178) ']\t'],str{1});
    end
    if get(hMainGui.RightPanel.pTools.cIntegral,'Value')==1
        str{1}=sprintf('%sIntegral\t',str{1});
    end
    if get(hMainGui.RightPanel.pTools.cMean,'Value')==1
        str{1}=sprintf('%sMean\t',str{1});
    end
    if get(hMainGui.RightPanel.pTools.cSTD,'Value')==1
        str{1}=sprintf('%sSTD\t',str{1});
    end
    for i=1:length(hMainGui.Measure)
        str{i+1}=''; %#ok<AGROW>
        if get(hMainGui.RightPanel.pTools.cLengthArea,'Value')==1
            str{i+1}=sprintf('%s%f\t',str{i+1},hMainGui.Measure(i).LenArea); %#ok<AGROW>
        end
        if get(hMainGui.RightPanel.pTools.cIntegral,'Value')==1
            if hMainGui.Measure(i).Dim==1
                str{i+1}=sprintf('%s%f\t',str{i+1},hMainGui.Measure(i).Integral); %#ok<AGROW>
            else
                str{i+1}=sprintf('%s%f\t',str{i+1},hMainGui.Measure(i).Integral); %#ok<AGROW>
            end
        end
        if get(hMainGui.RightPanel.pTools.cMean,'Value')==1
            str{i+1}=sprintf('%s%f\t',str{i+1},hMainGui.Measure(i).Mean); %#ok<AGROW>
        end
        if get(hMainGui.RightPanel.pTools.cSTD,'Value')==1
             str{i+1}=sprintf('%s%f\t',str{i+1},hMainGui.Measure(i).STD);%#ok<AGROW>
        end
    end
    f=fopen(file,'w');
    for i=1:length(str)
        fprintf(f,'%s\n',str{i});
    end
    fclose(f);
end
fShared('ReturnFocus');

function SubtractDrift(hMainGui)
global Molecule;
global Filament;
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)  
    nMol=length(Molecule);
    nFil=length(Filament);
    aligned = 0; %JochenK: Progressdialogue and aligned check are new
    if gcbo==hMainGui.RightPanel.pData.cMolDrift
        for i=1:nMol
            if Molecule(i).TformMat(3,3)==0
                aligned = 1;
            end
        end
    else
        for i=1:nFil
            if Filament(i).TformMat(3,3)==0
                aligned = 1;
            end
        end
    end
    answer = 'Yes';
    if aligned
        answer = questdlg('Some objects are color-aligned. Maybe you should first unalign them by clicking "Align Channels" and then realign them after drift correction. Continue anyway?', 'Warning', 'Yes','No','No' );
    end
    if strcmp(answer, 'Yes')
        hfDataGui=hMainGui.Extensions.JochenK.fDataGui;
        hfDataGui('DeleteGUI',1);
        Value=get(gcbo,'Value');
        if gcbo==hMainGui.RightPanel.pData.cMolDrift
            progressdlg('String','Correcting Molecules','Min',1,'Max',nMol);
            for i=1:nMol
                if length(Drift)>=Molecule(i).Channel && ~isempty(Drift{Molecule(i).Channel})
                    Molecule(i)=fCalcDrift(Molecule(i),Drift{Molecule(i).Channel},Value);
                end
                progressdlg(i);
            end
        else
            progressdlg('String','Correcting Filaments','Min',1,'Max',nFil);
            for i=1:nFil
                if length(Drift)>=Filament(i).Channel && ~isempty(Drift{Filament(i).Channel})
                    Filament(i)=fCalcDrift(Filament(i),Drift{Filament(i).Channel},Value);
                end
                progressdlg(i);
            end
        end
        fShow('Tracks');
    end
end
set(hMainGui.RightPanel.pData.cMolDrift,'Value',all([Molecule.Drift]));
set(hMainGui.RightPanel.pData.cFilDrift,'Value',all([Filament.Drift]));  
fShared('ReturnFocus');

function CheckDrift(hMainGui)
global Molecule
global Filament
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)
    set(hMainGui.RightPanel.pData.cMolDrift,'Value',all([Molecule.Drift]));   %JochenK
    set(hMainGui.RightPanel.pData.cFilDrift,'Value',all([Filament.Drift]));   %JochenK     
    fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
    fShow('Tracks');    
end
fShared('ReturnFocus');

function ShowAllFil
fShared('ReturnFocus');
fShared('UpdateMenu',getappdata(0,'hMainGui'));
fShow('Image');

function ListButton(hMainGui,type)
global Molecule;
global Filament;
if ~hMainGui.Extensions.JochenK.Data
    fShared('BackUp',hMainGui);
end
hfDataGui=hMainGui.Extensions.JochenK.fDataGui;
if strcmp(type,'Molecule')
    Object=Molecule;
else
    Object=Filament;
end
nObj=length(Object);
idx=get(gcbo,'UserData');
if strcmp(type,'Molecule')==1
    value=round(get(hMainGui.RightPanel.pData.sMolList,'Value'));
else
    value=round(get(hMainGui.RightPanel.pData.sFilList,'Value'));
end
if nObj>8
    hfDataGui('Create',type,nObj-7-value+idx);
else
    hfDataGui('Create',type,idx);
end


function QueueCheck(hMainGui)
global Queue;
nQue=length(Queue);
idx=get(gcbo,'UserData');
value=round(get(hMainGui.RightPanel.pQueue.sLocList,'Value'));
if nQue>8
    Queue(nQue-7-value+idx).Check=get(gcbo,'Value');
else
    Queue(idx).Check=get(gcbo,'Value');
end
fShared('ReturnFocus');

function ListVisible(hMainGui,Mode) %JochenK BugFixCandidate
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
idx=get(gcbo,'UserData');
if strcmp(Mode,'Molecule')
    Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,idx*1i,[],hMainGui.RightPanel.pData.sMolList);
else
    Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,idx*1i,[],hMainGui.RightPanel.pData.sFilList);
end
fShared('ReturnFocus');
fShow('Image');

function ListSlider(hMainGui)
global Molecule;
global Filament;
fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK
fShared('ReturnFocus');

function ShowKymoGraph(hMainGui)
DeleteScan(hMainGui,0);                              %JochenK
NewKymoGraph(hMainGui);
fShared('ReturnFocus');

function IgnoreObjects(hMainGui,Mode)               %JochenK BugFixCandidate
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Value=get(gcbo,'Value');
if strcmp(Mode,'Molecule')
    Object=Molecule;
    KymoObject=KymoTrackMol;
else
    Object=Filament;
    KymoObject=KymoTrackFil;
end
for n=1:length(Object)
    Object(n).Selected=-Value;
    visible='off';
    if Object(n).Selected==0&&Object(n).Visible==1
        visible='on';
    end
    set(Object(n).PlotHandles(1),'Visible',visible);
    k=find([KymoObject.Index]==n);
    if ~isempty(k)
        set(KymoObject(k).PlotHandles(1),'Visible',visible);                 
    end  
end
if strcmp(Mode,'Molecule')
    Molecule=Object;
else
    Filament=Object;
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK
fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
fShared('ReturnFocus');

function KymoFrames(hMainGui)
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    stidx=hMainGui.Values.FrameIdx(1);
    if stidx>length(hMainGui.Values.MaxIdx)-1
        N = hMainGui.Values.MaxIdx(2);
    else
        N = hMainGui.Values.MaxIdx(stidx+1);
    end
else
    N = max(hMainGui.Values.MaxIdx(2:end));
end
if strcmp(get(gcbo,'UserData'),'Start')
    s=min([s e-1]);
    s=max([s 1]);
    e=max([e s+1]);
else    
    e=min([e N]);
 	e=max([e s+1]);
end    
set(hMainGui.RightPanel.pTools.eKymoStart,'String',num2str(s));
set(hMainGui.RightPanel.pTools.eKymoEnd,'String',num2str(e));
fShared('ReturnFocus');

function ScanSize(hMainGui)
value=round(str2double(get(hMainGui.RightPanel.pTools.eScanSize,'String')));
if value<1
    value=1;
end
if ~isnan(value)
   if value>10
       value=10;
   end
   hMainGui.Values.ScanSize=value;
   setappdata(0,'hMainGui',hMainGui);
   NewScan(hMainGui);
end
set(hMainGui.RightPanel.pTools.eScanSize,'String',num2str(value));
fShared('ReturnFocus');

function MeasureTable(hMainGui)
idx=get(hMainGui.RightPanel.pTools.lMeasureTable,'Value');
set(hMainGui.RightPanel.pTools.lMeasureTable,'UserData',idx-1);
setappdata(0,'hMainGui',hMainGui);
fShared('ReturnFocus');

function str=formatstr(width,format,value)
str=sprintf(format,value);
str = strrep(str, 'e+00', 'e+');
l=width-length(str);
for i=0.5:0.5:l
    str=[' ' str]; %#ok<AGROW>
end

function hMainGui = UpdateLineScan(hMainGui)
global Stack
stidx=hMainGui.Values.FrameIdx(1);
if length(hMainGui.Values.FrameIdx)>2
    idx=hMainGui.Values.FrameIdx(stidx+1);
else
    idx=hMainGui.Values.FrameIdx(2);
end
if all(isreal(idx)) && all(idx)>0
    if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
        Image=double(Stack{stidx}(:,:,idx));
    else
        for n = 1:length(hMainGui.Values.StackColor)
            t = min([n+1 length(hMainGui.Values.FrameIdx)]);
            idx(n) = hMainGui.Values.FrameIdx(t);
            Image(:,:,n)=double(Stack{n}(:,:,idx(n)));
        end
    end   
else
    cidx = imag(idx);
    switch(cidx)
        case {-1,-4} %Maximum or objects profection
            Image = double(getappdata(hMainGui.fig,'MaxImage'));
            if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                Image = Image(:,:,stidx);
            end
        case -2 %Average
            Image=double(getappdata(hMainGui.fig,'AverageImage'));
            if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
                Image = Image(:,:,stidx);
            end
        otherwise
            idx = real(idx);
            Image = double(Stack{stidx}(:,:,idx));
    end
end
if (strcmp(get(hMainGui.Menu.mAlignChannels,'Checked'),'on')&&strcmp(get(hMainGui.Menu.mAlignChannels,'Enable'),'on'))||(strcmp(get(hMainGui.ToolBar.ToolThreshImage,'State'),'on')&&~isempty(hMainGui.Values.PostSpecial)&&~strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'on'))
    for n = 2:size(Image,3)
        T = hMainGui.Values.TformChannel{n};
        T(end) = 1;
        Image(:,:,n) = quickwarp(Image(:,:,n),T,0);
    end
end
for n = 1:size(Image,3)
    Z = interp2(double(Image(:,:,n)),hMainGui.Scan.InterpX,hMainGui.Scan.InterpY);
    I(n,:) = mean(Z,1);
end
set(0,'CurrentFigure',hMainGui.fig);
set(hMainGui.fig,'CurrentAxes',hMainGui.RightPanel.pTools.aLineScan);
set(hMainGui.RightPanel.pTools.pLineScan,'Visible','on');
set(hMainGui.RightPanel.pTools.aLineScan,'Visible','on');
delete(findobj('Tag','plotLineScan'));
if size(I,1)>1
    for n = 1:size(I,1)
        c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
        c = squeeze(c(1,1,1:3));
        line(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I(n,:),'Color',c,'LineStyle','-','UIContextMenu',hMainGui.Menu.ctScan,'Tag','plotLineScan');
    end
else
    line(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000,I,'Color','black','LineStyle','-','UIContextMenu',hMainGui.Menu.ctScan,'Tag','plotLineScan');
end
xlim([0 max(hMainGui.Scan.InterpD*hMainGui.Values.PixSize/1000)]);
xlabel(['Distance [' char(956) 'm]']);
ylabel('Intensity [counts]');
hMainGui.Scan.I = I;

function NewKymoGraph(hMainGui)
global Stack;
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
if ~isnan(s)&&~isnan(e)&&~isempty(Stack)
    if hMainGui.Extensions.JochenK.Kymo&&strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'on')
        [KymoGraph,KymoPixSize]=fJKNewKymo(hMainGui.Scan, Stack);
    elseif hMainGui.Extensions.JochenK.Kymo
        [KymoGraph,KymoPixSize]=NewHighResKymo(hMainGui.Scan);
    else
        [KymoGraph,KymoPixSize]=NewKymo(hMainGui.Scan);
    end
    KymoGraph(e+1:end,:,:)=[];
    KymoGraph(1:s-1,:,:)=[];
%     try %JochenK
%         delete(hMainGui.MidPanel.aKymoGraph);
%     catch
%         delete(findobj('Tag','aKymoGraph'));
%     end
    hMainGui.MidPanel.aKymoGraph = axes('Parent',hMainGui.MidPanel.pKymoGraph,'Units','normalized','UIContextMenu',hMainGui.Menu.ctKymoGraph,'Position',[0 0 1 1],'Tag','aKymoGraph','NextPlot','add','Visible','off');  
    [y,x,~]=size(KymoGraph);
    if y/x >= hMainGui.ZoomKymo.aspect
        borders = ((y/hMainGui.ZoomKymo.aspect)-x)/2;
        hMainGui.ZoomKymo.globalXY = {[0.5-borders x+0.5+borders],[0.5 y+0.5]};
    else
        borders = ((x*hMainGui.ZoomKymo.aspect)-y)/2;
        hMainGui.ZoomKymo.globalXY = {[0.5 x+0.5],[0.5-borders y+0.5+borders]};
    end
    hMainGui.KymoImage=KymoGraph;
    if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
        n = hMainGui.Values.FrameIdx(1);
        Image=(KymoGraph-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
    else
        IRGB = zeros(size(KymoGraph,1),size(KymoGraph,2),3);
        for n = 1:length(hMainGui.Values.StackColor)
            c = get(hMainGui.ToolBar.ToolColors(hMainGui.Values.StackColor(n)),'CData');
            c = squeeze(c(1,1,1:3));
            KymoGraph(:,:,n) = (KymoGraph(:,:,n)-hMainGui.Values.ScaleMin(n))/(hMainGui.Values.ScaleMax(n)-hMainGui.Values.ScaleMin(n)+1);
            IRGB(:,:,1) = IRGB(:,:,1)+KymoGraph(:,:,n)*c(1);
            IRGB(:,:,2) = IRGB(:,:,2)+KymoGraph(:,:,n)*c(2);
            IRGB(:,:,3) = IRGB(:,:,3)+KymoGraph(:,:,n)*c(3);
        end
        Image = IRGB;
    end
    Image(Image<0)=0;
    Image(Image>1)=1;
    if size(Image,3)==1
       Image=Image*2^16;
    end
    hMainGui.KymoGraph=image(Image,'Parent',hMainGui.MidPanel.aKymoGraph,'CDataMapping','scaled');
    set(hMainGui.MidPanel.aKymoGraph,'CLim',[0 65535],'YDir','reverse'); 
    set(hMainGui.MidPanel.aKymoGraph,'Visible','on'); 
    set(hMainGui.fig,'colormap',colormap('Gray'));
    set(hMainGui.KymoGraph,'Tag','plotScan','UserData',KymoPixSize);
    if hMainGui.Extensions.JochenK.TracksKymo
        hfShowTracksKymo = @JKShowTracksKymo;
    else
        hfShowTracksKymo = @ShowTracksKymo;
    end
    if ~isempty(Molecule)
        [hMainGui,KymoTrackMol]=hfShowTracksKymo(hMainGui,Molecule,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    if ~isempty(Filament)
        [hMainGui,KymoTrackFil]=hfShowTracksKymo(hMainGui,Filament,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    set(hMainGui.MidPanel.aKymoGraph,{'xlim','ylim'},hMainGui.ZoomKymo.globalXY,'Visible','off'); 
    hMainGui.ZoomKymo.currentXY=hMainGui.ZoomKymo.globalXY;
    hMainGui.ZoomKymo.level=0;
    setappdata(0,'hMainGui',hMainGui);
%     if gcbo == hMainGui.RightPanel.pTools.bShowKymoGraph %JochenK
    fToolBar('KymoGraph',hMainGui)
%     end
end

function [KymoGraph,KymoPix] = NewHighResKymo(Scan)
global Stack;
iX=Scan.InterpX;
iY=Scan.InterpY;
d = Scan.InterpD;
KymoPix = mean(d(2:end)-d(1:end-1));
hMainGui=getappdata(0,'hMainGui'); 
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    stidx=hMainGui.Values.FrameIdx(1);
    if stidx>length(hMainGui.Values.MaxIdx)-1
        N = hMainGui.Values.MaxIdx(2);
    else
        N = hMainGui.Values.MaxIdx(stidx+1);
    end
else
    stidx=1:numel(Stack);
    N = max(hMainGui.Values.MaxIdx(2:end));
end
progressdlg('String','Creating KymoGraph','Min',0,'Max',N,'Parent',hMainGui.fig);
KymoGraph = zeros(N,length(d),length(stidx)); 

for n = 1:N
    for k = stidx
            Z = interp2(double(Stack{k}(:,:,n)),iX,iY,'linear');
            KymoGraph(n,:,k) = (nansum(Z, 1)-sum(~isnan(Z),1).*min(min(double(Z), [], 1)));
    end
    progressdlg(n);
end 
KymoGraph = KymoGraph(:,:,stidx);


function [KymoGraph,KymoPix] = NewKymo(Scan)
global Stack;
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
iX=Scan.InterpX;
iY=Scan.InterpY;
d = Scan.InterpD;
KymoPix = mean(d(2:end)-d(1:end-1));
hMainGui=getappdata(0,'hMainGui'); 
if strcmp(get(hMainGui.ToolBar.ToolChannels(5),'State'),'off')
    stidx=hMainGui.Values.FrameIdx(1);
    if stidx>length(hMainGui.Values.MaxIdx)-1
        N = hMainGui.Values.MaxIdx(2);
    else
        N = hMainGui.Values.MaxIdx(stidx+1);
    end
else
    stidx=1:numel(Stack);
    N = max(hMainGui.Values.MaxIdx(2:end));
end
for k = stidx
    if length(Drift)<k || isempty(Drift{k})
        Drift{k} = [ 1 0 0 ];
    end
end
progressdlg('String','Creating KymoGraph','Min',0,'Max',N,'Parent',hMainGui.fig);
KymoGraph = zeros(N,length(d),length(stidx)); 
correctDrift = get(hMainGui.RightPanel.pTools.cKymoDrift,'Value') && ~isempty(Drift) && strcmp(get(hMainGui.RightPanel.pTools.cKymoDrift,'Enable'),'on');
if correctDrift
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for n = 1:N
            for k = stidx
                [~,m]=min(abs(Drift{k}(:,1)-n));
                if n>size(Stack{k},3)
                    KymoGraph(n,:,k)=KymoGraph(n-1,:,k);
                else
                    Z = interp2(double(Stack{k}(:,:,n)),iX+Drift{k}(m,2)/hMainGui.Values.PixSize,iY+Drift{k}(m,3)/hMainGui.Values.PixSize,'nearest');
                    KymoGraph(n,:,k)=max(Z,[],1);
                end
            end
            progressdlg(n);
        end
    else
        for n = 1:N
            for k = stidx
                [~,m]=min(abs(Drift{k}(:,1)-n));
                if n>size(Stack{k},3)
                    KymoGraph(n,:,k)=KymoGraph(n-1,:,k);
                else
                    Z = interp2(double(Stack{k}(:,:,n)),iX+Drift{k}(m,2)/hMainGui.Values.PixSize,iY+Drift{k}(m,3)/hMainGui.Values.PixSize);
                    KymoGraph(n,:,k)=mean(Z,1);
                end
            end
            progressdlg(n);
        end 
        KymoGraph(isnan(KymoGraph))=0;
    end
else
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for n = 1:N
            for k = stidx
                if n>size(Stack{k},3)
                    KymoGraph(n,:,k)=KymoGraph(n-1,:,k);
                else
                    Z = interp2(double(Stack{k}(:,:,n)),iX,iY,'nearest');
                    KymoGraph(n,:,k)=max(Z,[],1);
                end
            end
            progressdlg(n);
        end
    else
        for n = 1:N
            for k = stidx
                if n>size(Stack{k},3)
                    KymoGraph(n,:,k)=KymoGraph(n-1,:,k);
                else
                    Z = interp2(double(Stack{k}(:,:,n)),iX,iY);
                    KymoGraph(n,:,k)=mean(Z,1);
                end
            end
            progressdlg(n);
        end 
    end
end
KymoGraph = KymoGraph(:,:,stidx);

function UpdateKymoTracks(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
s=str2double(get(hMainGui.RightPanel.pTools.eKymoStart,'String'));
e=str2double(get(hMainGui.RightPanel.pTools.eKymoEnd,'String'));
if ~isempty(hMainGui.KymoImage)
    KymoPixSize = get(hMainGui.KymoGraph,'UserData');
    if hMainGui.Extensions.JochenK.TracksKymo
        hfShowTracksKymo = @JKShowTracksKymo;
    else
        hfShowTracksKymo = @ShowTracksKymo;
    end
    DeleteHandles; %JochenK
    if ~isempty(Molecule)
        [hMainGui,KymoTrackMol]=hfShowTracksKymo(hMainGui,Molecule,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
    if ~isempty(Filament)
        [hMainGui,KymoTrackFil]=hfShowTracksKymo(hMainGui,Filament,hMainGui.Scan.InterpX,hMainGui.Scan.InterpY,s,e,hMainGui.Scan.lx,hMainGui.Scan.ux,hMainGui.Scan.ly,hMainGui.Scan.uy,KymoPixSize);
    end
end
setappdata(0,'hMainGui',hMainGui);

function CreateFilamentScan(hMainGui)
global Filament;
DeleteScan(hMainGui,0);                              %JochenK
k = find([Filament.Selected]==1);
if isempty(k)
    fMsgDlg('No filament selected','error');
else
    hMainGui.Scan(1).X = (double(Filament(k(1)).Data{1}(:,1))/Filament(k(1)).PixelSize)';
    hMainGui.Scan(1).Y = (double(Filament(k(1)).Data{1}(:,2))/Filament(k(1)).PixelSize)';
    hMainGui.KymoName = Filament.Name;                  %JochenK
    NewScan(hMainGui)
end

function NewScan(hMainGui)
set(0,'CurrentFigure',hMainGui.fig);
set(hMainGui.fig,'CurrentAxes',hMainGui.MidPanel.aView);
nX=hMainGui.Scan.X';
nY=hMainGui.Scan.Y';
ScanSize=hMainGui.Values.ScanSize;
res = 2;
d=[0; cumsum(sqrt((nX(2:end)-nX(1:end-1)).^2 + (nY(2:end)-nY(1:end-1)).^2))];
dt=max(d)/(round(max(d))*res);
id=(0:round(max(d))*res)'*dt;
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
d = [0; cumsum(sqrt((X(2:end)-X(1:end-1)).^2 + (Y(2:end)-Y(1:end-1)).^2))];
lx = iX(1,:);
ux = iX(end,:);
ly = iY(1,:);
uy = iY(end,:);
delete(findobj('Tag','plotScan'));
line(X,Y,'Color','red','LineStyle','-.','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan);
line(lx,ly,'Color','red','LineStyle',':','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan);
line(ux,uy,'Color','red','LineStyle',':','Tag','plotScan','UIContextMenu',hMainGui.Menu.ctScan);
hMainGui.Scan.InterpX=iX;
hMainGui.Scan.InterpY=iY;
hMainGui.Scan.lx=lx;
hMainGui.Scan.ux=ux;
hMainGui.Scan.ly=ly;
hMainGui.Scan.uy=uy;
hMainGui.Scan.InterpD=d;
hMainGui.CursorMode='Normal';
set(hMainGui.RightPanel.pTools.bLineScanExport,'Enable','on');
set(hMainGui.RightPanel.pTools.bShowKymoGraph,'Enable','on');
if isempty(getappdata(hMainGui.fig,'Drift')) %JochenK
    set(hMainGui.RightPanel.pTools.cKymoDrift,'Enable','off','Value',0);
elseif ~get(hMainGui.RightPanel.pTools.cKymoDrift,'Value') && strcmp(get(hMainGui.RightPanel.pTools.cKymoDrift,'Enable'), 'on')
    set(hMainGui.RightPanel.pTools.cKymoDrift,'Enable','on');
end
setappdata(0,'hMainGui',hMainGui);
hMainGui = UpdateLineScan(hMainGui);
AllToolsOff(hMainGui);
fToolBar('Cursor',hMainGui);

function DeleteHandles 
%JochenK
global KymoTrackMol;
global KymoTrackFil;
for temp=KymoTrackFil
   h=temp.PlotHandles;
   delete(h(ishandle(h)));
end
for temp=KymoTrackMol
   h=temp.PlotHandles;
   delete(h(ishandle(h)));
end
KymoTrackMol(:)=[];
KymoTrackFil(:)=[];

function DeleteScan(hMainGui, varargin)
%JochenK: reorganized the function and made it more flexible and added utility, but it is
%essentially the same as before
if nargin>1
    DeleteCompletely=varargin{1};
else
    DeleteCompletely=1;
end
hMainGui.Values.CursorDownPos(:)=0; 
delete(hMainGui.Plots.Measure(:));    
hMainGui.Measure(:)=[];
hMainGui.Plots.Measure(:)=[];
fRightPanel('UpdateMeasure',hMainGui);
plotScan=findobj('Tag','plotScan');
hMainGui.KymoGraph=[];
hMainGui.KymoImage=[];
if DeleteCompletely
%     hMainGui.Scan = struct('X',[0 0],'Y',[0 0]); %JochenK. Formerly hMainGui.Scan=[];
    hMainGui.KymoName = '';
end
if ~isempty(plotScan)
    hMainGui.Values.CursorDownPos(:)=0;
    DeleteHandles;
    delete(findobj('Tag','plotLineScan'));
    cla(hMainGui.MidPanel.aKymoGraph,'reset');
    if DeleteCompletely
        delete(plotScan);
        cla(hMainGui.RightPanel.pTools.aLineScan,'reset');
        set(hMainGui.RightPanel.pTools.bLineScanExport,'Enable','off');
        set(hMainGui.RightPanel.pTools.bShowKymoGraph,'Enable','off');
    end
    fToolBar('NormImage',hMainGui);
else
    setappdata(0,'hMainGui',hMainGui);    
end            


function [hMainGui,KymoTrackObj]=ShowTracksKymo(hMainGui,Objects,X,Y,s,e,lx,ux,ly,uy,KymoPixSize)
set(0,'CurrentFigure',hMainGui.fig);
set(hMainGui.fig,'CurrentAxes',hMainGui.MidPanel.aKymoGraph);
KymoTrackObj=struct('Index',{},'Track',{},'PlotHandles',{});
nTrack=1;
newX=mean(X,1);
newY=mean(Y,1);
fi = 1:0.1:numel(newX);
newX = interp1(1:numel(newX),newX,fi);
newY = interp1(1:numel(newY),newY,fi);
stidx = getChannels;
kObj = find(ismember([Objects.Channel],stidx));
for idx=kObj
    polyX=[lx ux(length(ux):-1:1)];
    polyY=[ly uy(length(uy):-1:1)];    
    OX=Objects(idx).Results(:,3)/hMainGui.Values.PixSize;
    OY=Objects(idx).Results(:,4)/hMainGui.Values.PixSize;
    IN=find(inpolygon(OX,OY,polyX,polyY)==1);
    k=find(Objects(idx).Results(IN,1)>=s&Objects(idx).Results(IN,1)<=e);
    KymoTrack=[];
    for n=1:length(k)
        [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
        KymoTrack(n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; %#ok<AGROW> 
    end
    if isfield(Objects(idx),'PosStart') && ~isempty(KymoTrack)
        KymoTrack(end+1,:) = NaN;%#ok<AGROW> 
        OX=Objects(idx).PosStart(:,1)/hMainGui.Values.PixSize;
        OY=Objects(idx).PosStart(:,2)/hMainGui.Values.PixSize;
        for n=1:length(k)
            [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
            KymoTrack(length(k)+1+n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; 
        end
        KymoTrack(end+1,:) = NaN;%#ok<AGROW> 
        OX=Objects(idx).PosEnd(:,1)/hMainGui.Values.PixSize;
        OY=Objects(idx).PosEnd(:,2)/hMainGui.Values.PixSize;
        for n=1:length(k)
            [~,t]=min(sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2));
            KymoTrack(2*length(k)+2+n,1:2)=[Objects(idx).Results(IN(k(n)),1)-s+1 fi(t)*KymoPixSize]; 
        end
    end
    if ~isempty(KymoTrack)
        KymoTrackObj(nTrack).RefPos='PosCenter'; %JochenK
        KymoTrackObj(nTrack).Name=Objects(idx).Name;
        KymoTrackObj(nTrack).Index=idx;        
        KymoTrackObj(nTrack).Track=KymoTrack;        
        KymoTrackObj(nTrack).PlotHandles(1,1) = line(KymoTrack(:,2),KymoTrack(:,1),'Color',Objects(idx).Color,'Visible','off','Tag','pKymoTracks');
        if Objects(idx).Visible
            set(KymoTrackObj(nTrack).PlotHandles(1,1),'Visible','on');
        end
        nTrack=nTrack+1;
    end
end

% function CorrectKymoIndex(mode)
% global Molecule;
% global Filament;
% global KymoTrackMol;
% global KymoTrackFil;
% if strcmp(mode,'Molecule')
%     Objects=Molecule;
%     KymoTrack=KymoTrackMol;
% else
%     Objects=Filament;
%     KymoTrack=KymoTrackFil;
% end
% Names=cell(1,length(Objects));
% for n=1:length(Objects)
%     Names{n}=Objects(n).Name;
% end    
% for n=1:length(KymoTrack)
%     KymoTrack(n).Index=strmatch(KymoTrack(n).Name, Names);    
% end
% if strcmp(mode,'Molecule')
%     Molecule=Objects; JochenK CountBugFix
%     KymoTrackMol=KymoTrack;
% else
%     Filament=Objects; JochenK CountBugFix
%     KymoTrackFil=KymoTrack;
% end
    

function UpdateMeasure(hMainGui)
str{1}='';
sprintf('Length/Area   Integral  Mean  STD');
if get(hMainGui.RightPanel.pTools.cLengthArea,'Value')==1
     str{1}=[str{1} 'Length/Area   '];
end
if get(hMainGui.RightPanel.pTools.cIntegral,'Value')==1
    str{1}=[str{1} 'Integral     '];
end
if get(hMainGui.RightPanel.pTools.cMean,'Value')==1
    str{1}=[str{1} '    Mean     '];
end
if get(hMainGui.RightPanel.pTools.cSTD,'Value')==1
    str{1}=[str{1} '     STD'];
end
for i=1:length(hMainGui.Measure)
     str{i+1}=''; %#ok<AGROW>
     if get(hMainGui.RightPanel.pTools.cLengthArea,'Value')==1
         str{i+1}=[str{i+1} formatstr(7,'%.3f',hMainGui.Measure(i).LenArea)]; %#ok<AGROW>
         if hMainGui.Measure(i).Dim==1
             str{i+1}=[str{i+1} char(956) 'm     ']; %#ok<AGROW>
         else
             str{i+1}=[str{i+1} char(956) 'm' char(178) '   ']; %#ok<AGROW>
          end
     end
     if get(hMainGui.RightPanel.pTools.cIntegral,'Value')==1
         if hMainGui.Measure(i).Dim==1
             str{i+1}=[str{i+1} formatstr(7,'%.0f',hMainGui.Measure(i).Integral) '     ']; %#ok<AGROW>
         else
             str{i+1}=[str{i+1} formatstr(7.5,'%.2e',hMainGui.Measure(i).Integral) '     ']; %#ok<AGROW>
         end
     end
     if get(hMainGui.RightPanel.pTools.cMean,'Value')==1
         str{i+1}=[str{i+1} formatstr(7,'%.1f',hMainGui.Measure(i).Mean) '     ']; %#ok<AGROW>
     end
     if get(hMainGui.RightPanel.pTools.cSTD,'Value')==1
         str{i+1}=[str{i+1} formatstr(7,'%.2f',hMainGui.Measure(i).STD) '     ']; %#ok<AGROW>
     end
end
if isempty(hMainGui.Measure)
    set(hMainGui.RightPanel.pTools.lMeasureTable,'String','','UIContextMenu','','Value',1);
else
    set(hMainGui.RightPanel.pTools.lMeasureTable,'String',str,'UIContextMenu',hMainGui.Menu.ctMeasure,'Value',length(str));
end
set(hMainGui.fig,'pointer','arrow');
setappdata(0,'hMainGui',hMainGui);


function SetAllPanelsOff(hMainGui)
set(hMainGui.RightPanel.pData.panel,'Visible','off');
set(hMainGui.RightPanel.pTools.panel,'Visible','off');
set(hMainGui.RightPanel.pQueue.panel,'Visible','off');

function DataPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');

function ToolsPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');

function QueuePanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');

function DataMoleculesPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');
set(hMainGui.RightPanel.pData.pMoleculesPan,'Visible','on');
set(hMainGui.RightPanel.pData.pFilamentsPan,'Visible','off');

function DataFilamentsPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pData.panel,'Visible','on');
set(hMainGui.RightPanel.pData.pMoleculesPan,'Visible','off');
set(hMainGui.RightPanel.pData.pFilamentsPan,'Visible','on');

function ToolsMeasurePanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');
set(hMainGui.RightPanel.pTools.pMeasurePan,'Visible','on');
set(hMainGui.RightPanel.pTools.pScanPan,'Visible','off');

function ToolsScanPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pTools.panel,'Visible','on');
set(hMainGui.RightPanel.pTools.pMeasurePan,'Visible','off');
set(hMainGui.RightPanel.pTools.pScanPan,'Visible','on');

function QueueServerPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');
set(hMainGui.RightPanel.pQueue.pServerPan,'Visible','on');
set(hMainGui.RightPanel.pQueue.pLocalPan,'Visible','off');

function QueueLocalPanel(hMainGui)
SetAllPanelsOff(hMainGui);
set(hMainGui.RightPanel.pQueue.panel,'Visible','on');
set(hMainGui.RightPanel.pQueue.pServerPan,'Visible','off');
set(hMainGui.RightPanel.pQueue.pLocalPan,'Visible','on');

function AllToolsOff(hMainGui)
set(hMainGui.RightPanel.pTools.bLine,'Value',0);
set(hMainGui.RightPanel.pTools.bSegLine,'Value',0);
set(hMainGui.RightPanel.pTools.bFreehand,'Value',0);
set(hMainGui.RightPanel.pTools.bRectangle,'Value',0);
set(hMainGui.RightPanel.pTools.bEllipse,'Value',0);
set(hMainGui.RightPanel.pTools.bPolygon,'Value',0);
set(hMainGui.RightPanel.pTools.bLineScan,'Value',0);
set(hMainGui.RightPanel.pTools.bSegLineScan,'Value',0);
set(hMainGui.RightPanel.pTools.bFreehandScan,'Value',0);
if isfield(hMainGui,'Plots')
    if isfield(hMainGui.Plots,'Measure')
        nMeasure=length(hMainGui.Plots.Measure);
        if nMeasure>0
            color=get(hMainGui.Plots.Measure(nMeasure),'Color');    
            if sum(color)==3
                hMainGui.Values.CursorDownPos(:)=0; 
                delete(hMainGui.Plots.Measure(nMeasure));    
                hMainGui.Measure(nMeasure)=[];
                hMainGui.Plots.Measure(nMeasure)=[];
            end
        end
    end
    if isfield(hMainGui,'Region')
        nRegion=length(hMainGui.Region);
        if nRegion>0
            try %JochenK
                color=get(hMainGui.Plots.Region(nRegion),'Color');    
                if sum(color)==3
                    hMainGui.Values.CursorDownPos(:)=0; 
                    delete(hMainGui.Plots.Region(nRegion));
                    hMainGui.Region(nRegion)=[];
                    hMainGui.Plots.Region(nRegion)=[];
                end
            catch
            end
        end
    end
end
plotScan=findobj('Tag','plotScan','-and','Type','line');
if ~isempty(plotScan)
    color=get(plotScan(1),'Color');    
    if sum(color)==3
        hMainGui.Values.CursorDownPos(:)=0;
        delete(plotScan);    
%         hMainGui.Scan = struct('X',[0 0],'Y',[0 0]); %JochenK. Formerly hMainGui.Scan=[];
    end
end
setappdata(0,'hMainGui',hMainGui);

function ToggleTool(hMainGui)
value=get(gcbo,'Value');
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(gcbo,'Value',value);
if value==1
    if strcmp(get(gcbo,'UserData'),'FilamentScan')
        set(gcbo,'Value',0);
    	CreateFilamentScan(hMainGui);
        hMainGui=getappdata(0,'hMainGui');
    else
        hMainGui.CursorMode=get(gcbo,'UserData');
    end
else
    hMainGui.CursorMode='Normal';
end
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function UpdateList(pData,List,UIContext, varargin) %JochenK
l=length(List);
if isfield(List, 'PosCenter')
    slider = pData.sFilList;
    hList = pData.FilList;
    set(pData.tFilamentsM, 'String', ['Filaments (' int2str(l) ')']);
    set(pData.tFilamentsF, 'String', ['Filaments (' int2str(l) ')']);
else
    slider = pData.sMolList;
    hList = pData.MolList;
    set(pData.tMoleculesM, 'String', ['Molecules (' int2str(l) ')']);
    set(pData.tMoleculesF, 'String', ['Molecules (' int2str(l) ')']);
end
if l>8
    slider_step(1) = 1/(l-8);
    slider_step(2) = 8/(l-8);
    if strcmp(get(slider,'Enable'),'on')==1
        v=get(slider,'Value');
        if v>l-7
            v=l-7;
        end
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',v)
    else
        set(slider,'sliderstep',slider_step,...
         'max',l-7,'min',1,'Value',l-7,'Enable','on')
    end
    ListBegin=(l-7)-round(get(slider,'Value'));
    ListLength=8;
else
    slider_step(1) = 0.1;
    slider_step(2) = 0.1;
    set(slider,'sliderstep',slider_step,...
         'max',1,'min',0,'Value',1,'Enable','off')
     ListLength=l;
     ListBegin=0;
end
CDataVisible(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CDataVisible(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CDataVisible(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
for i=1:ListLength
    fgcolor=[1 1 1];
    enableText='inactive';    
    enable='on';    
    bgcolor=[1.0000    0.9294    0.6275];
    try
        switch(List(i+ListBegin).Selected)
            case 2
                bgcolor=[0.8 0 0];
            case 1
                bgcolor=[0 0 0.8];
            case 0
                fgcolor=[0 0 0];
                ResultsLength = size(List(i+ListBegin).Results,1);
                if List(i+ListBegin).Results(end,1)==ResultsLength %JochenK
                    bgcolor=get(slider,'Background');
                    if nargin>3
                        if length(varargin{1})>=List(i+ListBegin).Channel+1
                            if varargin{1}(List(i+ListBegin).Channel+1)==ResultsLength
                                bgcolor=[0.6784    0.8667    0.5569];
                            end
                        end
                    end
                end
            otherwise
                bgcolor=get(slider,'Background');
                enable='off';
                enableText='off';  
        end
    catch
    end
    if List(i+ListBegin).Visible
        CData=CDataVisible;
    else
        CData=[];        
    end
    set(hList.Pan(i),'Visible','on','UIContextMenu',UIContext);    
    set(hList.Visible(i),'Enable',enable,'CData',CData,'UIContextMenu',UIContext);        
    set(hList.Name(i),'Enable',enableText,'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',UIContext,'String',List(i+ListBegin).Name);
    set(hList.File(i),'Enable',enableText,'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',UIContext,'String',List(i+ListBegin).File);
    set(hList.Back(i),'BackgroundColor',bgcolor);            
    set(hList.Button(i),'Enable',enable,'UIContextMenu',UIContext);
end
for i=ListLength+1:8
    set(hList.Pan(i),'Visible','off');    
end

function QueueSlider
Mode=get(gcbo,'UserData');
UpdateQueue(Mode);
fShared('ReturnFocus');

function UpdateQueue(mode)
hMainGui=getappdata(0,'hMainGui');
global Queue;
if strcmp(mode,'Local')
    hQueue=hMainGui.RightPanel.pQueue.LocList;
    slider=hMainGui.RightPanel.pQueue.sLocList;
    NewQueue=Queue;
else
    DirServer = fShared('CheckServer');
    hQueue=hMainGui.RightPanel.pQueue.SrvList;
    slider=hMainGui.RightPanel.pQueue.sSrvList;
    [NewQueue,Status]=fGetServerQueue;
end    
l=length(NewQueue);
if l>9
    slider_step(1) = 1/(l-9);
    slider_step(2) = 9/(l-9);
    if strcmp(get(slider,'Enable'),'on')==1
        v=get(slider,'Value');
        if v>l-8
            v=l-8;
        end
    else
        v=l-8;
    end
    set(slider,'sliderstep',slider_step,'max',l-8,'min',1,'Value',v,'Enable','on')
    QueueBegin=(l-8)-round(get(slider,'Value'));
    QueueLength=9;
else
    slider_step(1) = 0.1;
    slider_step(2) = 0.1;
    set(slider,'sliderstep',slider_step,...
         'max',1,'min',0,'Value',1,'Enable','off')
     QueueLength=l;
     QueueBegin=0;
end
for i=1:QueueLength
    bgcolor=get(slider,'Background');    
    fgcolor=[1 1 1];
    switch(NewQueue(i+QueueBegin).Selected)
        case 1
            bgcolor=[0 0 0.8];
        case 0
            fgcolor=[0 0 0];
    end            
    if strcmp(mode,'Local')
        set(hQueue.Pan(i),'Visible','on','UIContextMenu',hMainGui.Menu.ctListLoc);    
        set(hQueue.Name(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc,'String',NewQueue(i+QueueBegin).StackName);
        set(hQueue.File(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc,'String',NewQueue(i+QueueBegin).Directory);
        set(hQueue.Back(i),'BackgroundColor',bgcolor,'UIContextMenu',hMainGui.Menu.ctListLoc); 
    else
        set(hQueue.Pan(i),'Visible','on');    
        set(hQueue.Name(i),'Enable','inactive','BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'String',NewQueue(i+QueueBegin).StackName);
        set(hQueue.File(i),'BackgroundColor',bgcolor,'ForegroundColor',fgcolor,'Enable','inactive','String','');
        set(hQueue.Back(i),'BackgroundColor',bgcolor); 
    end
end
for i=QueueLength+1:9
    set(hQueue.Pan(i),'Visible','off');
end
if strcmp(mode,'Local')
    enable='off';
    if l>0
        enable='on';
    end
    set(hMainGui.Menu.mAnalyseQueue,'Enable',enable);
    set(hMainGui.RightPanel.pButton.bAnalyse,'Enable',enable);
else
    for n=1:length(Status)
        dirStatus = [DirServer 'Queue' filesep 'Job' int2str(Status(n).JobNr) filesep 'Status'];
        if isdir(dirStatus) && ~isempty(Status(n).FramesT)
            files = dir([dirStatus filesep '*.mat']);
            Status(n).StatusT = length(files)/Status(n).FramesT;
        else
            Status(n).StatusT = 0;
        end
        if isnan(Status(n).StatusT)
            Status(n).StatusT = 0;
        end
        if strcmp(get(slider,'Enable'),'on')==1 && l>9
            QueueNr = v-l+8 + n;
        else
            QueueNr=n;
        end
        if QueueNr>0
            set(hQueue.File(QueueNr),'String',{sprintf('Tracking: %3.0f%% (%s)',Status(n).StatusT*100,getTime(Status(n).TimeT,Status(n).StatusT)),...
                                               sprintf('Connecting: %3.0f%% (%s)',Status(n).StatusC*100,getTime(Status(n).TimeC,Status(n).StatusC)),...
                                               sprintf('Postprocessing: %3.0f%% (%s)',Status(n).StatusP*100,getTime(Status(n).TimeP,Status(n).StatusP))});
        end                                  
    end
end

function timeleft = getTime(starttime,status)
if status>0
    runtime = etime(clock,starttime);
    if runtime>0
        timeleft = sec2timestr( runtime/status - runtime );
    else
        timeleft = '??:??:??';
    end
else
    timeleft = '??:??:??';
end

function RefreshServerQueue(hMainGui)
DirServer = fShared('CheckServer');
if isempty(DirServer)
    fShared('ReturnFocus');
    return;
end
set(hMainGui.RightPanel.pQueue.bSrvRefresh,'String','Refresh SERVER Queue');
UpdateQueue('Server');
fShared('ReturnFocus');

function LoadQueue
global Queue;
[FileName, PathName] = uigetfile({'*.mat','FIESTA Queue(*.mat)'},'Load FIESTA Queue',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    Queue=fLoad([PathName FileName],'Queue');
    UpdateQueue('Local');    
end
fShared('ReturnFocus');

function SaveQueue
global Queue;
if ~isempty(Queue)
    [FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Queue',fShared('GetSaveDir'));
    if FileName~=0
        file = [PathName FileName];
        if isempty(findstr('.mat',file))
            file = [file '.mat'];
        end
        fShared('SetSaveDir',PathName);
        save(file,'Queue');
    end
end
fShared('ReturnFocus');

function timestr = sec2timestr(sec)
% Convert seconds to hh:mm:ss
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

if isnan(sec),
    h = 0;
    m = 0;
    s = 0;
end

if h < 10; h0 = '0'; else h0 = '';end     % Put leading zero on hours if < 10
if m < 10; m0 = '0'; else m0 = '';end     % Put leading zero on minutes if < 10
if s < 10; s0 = '0'; else s0 = '';end     % Put leading zero on seconds if < 10
timestr = strcat(h0,num2str(h),':',m0,...
          num2str(m),':',s0,num2str(s));

function [hMainGui,KymoTrackObj]=JKShowTracksKymo(hMainGui,Objects,X,Y,s,e,lx,ux,ly,uy,KymoPixSize)
set(0,'CurrentFigure',hMainGui.fig);
set(hMainGui.fig,'CurrentAxes',hMainGui.MidPanel.aKymoGraph);
KymoTrackObj=struct('Index',{},'Track',{},'PlotHandles',{});
nTrack=1;
newX=mean(X,1);
newY=mean(Y,1);
stidx = getChannels;
kObj = find(ismember([Objects.Channel],stidx));
if isfield(Objects, 'PosStart')
    fieldnames={'PosStart' 'PosEnd'};
    xcol=1;
    ycol=2;
else
    fieldnames={'Results'};
    xcol=3;
    ycol=4;
end
for idx=kObj
    for fieldname=fieldnames
    polyX=[lx ux(length(ux):-1:1)];
    polyY=[ly uy(length(uy):-1:1)];  
    OX=Objects(idx).(char(fieldname))(:,xcol)/hMainGui.Values.PixSize;
    OY=Objects(idx).(char(fieldname))(:,ycol)/hMainGui.Values.PixSize;
    IN=find(inpolygon(OX,OY,polyX,polyY)==1);
    k=find(Objects(idx).Results(IN,1)>=s&Objects(idx).Results(IN,1)<=e);
    KymoTrack=[];
    for n=1:length(k)
        minvec=sqrt( (newX-OX(IN(k(n)))).^2 + (newY-OY(IN(k(n)))).^2);
        [~,id]=min(minvec);
        if id>2&&length(minvec)>id+1
            t=id+(minvec(id-2)-minvec(id+2))/(minvec(id-2)/minvec(id-1));
        else
            t=id;
        end
        KymoTrack(n,:)=[Objects(idx).Results(IN(k(n)),1)-s+1 t*KymoPixSize]; %#ok<AGROW>
    end
    if ~isempty(KymoTrack)
        KymoTrackObj(nTrack).Index=idx;
        KymoTrackObj(nTrack).RefPos=char(fieldname);  
        KymoTrackObj(nTrack).Name=Objects(idx).Name;
        KymoTrackObj(nTrack).Track=KymoTrack;
        Tags=fJKfloat2tags(Objects(idx).Results(:,end));
        tagcol = hMainGui.Extensions.JochenK.ActiveTag;
        if strcmp(KymoTrackObj(nTrack).RefPos,'PosEnd')&&hMainGui.Extensions.JochenK.DynTags&&tagcol>5
            tagcol=tagcol+3;
        end
        KymoTrackObj(nTrack).Tags=Tags(:,tagcol);
        KymoTrackObj(nTrack).ObjFrames=Objects(idx).Results(:,1);
        KymoTrackObj(nTrack).Color=Objects(idx).Color;
        KymoTrackObj(nTrack).Visible=Objects(idx).Visible;
        KymoTrackObj(nTrack).PlotHandles(1,1) = line(KymoTrack(:,2),KymoTrack(:,1),'Color',Objects(idx).Color,'Visible','off');
        if Objects(idx).Visible
            set(KymoTrackObj(nTrack).PlotHandles(1,1),'Visible','on');
        end
        nTrack=nTrack+1;
    end
    end
end
direction=nan(length(KymoTrackObj),1);
for nTrack=1:length(KymoTrackObj)
    if isnan(direction(nTrack))
        if strcmp(KymoTrackObj(nTrack).RefPos,'Results')
            direction(nTrack)=0;
        else
            if nTrack<length(KymoTrackObj)
                if strcmp(KymoTrackObj(nTrack).Name,KymoTrackObj(nTrack+1).Name)
                    if KymoTrackObj(nTrack).Track(1,2)<KymoTrackObj(nTrack+1).Track(1,2)
                        direction(nTrack)=-1;
                        direction(nTrack+1)=+1;
                    else
                        direction(nTrack)=+1;
                        direction(nTrack+1)=-1;                    
                    end
                else
                    direction(nTrack)=-1;
                end
            else %last object, no direction determined yet
                direction(nTrack)=-1;
            end
        end
    end
end
colors = [1,0,1;0.896551724137931,1,0.793103448275862;1,0.586206896551724,0.793103448275862;1,0.965517241379310,0;0,0.413793103448276,0;0,0,0.620689655172414;1,1,1;0.379310344827586,0,0.344827586206897;0.517241379310345,0.413793103448276,0.275862068965517;0,1,0.655172413793103;0.689655172413793,0.482758620689655,1;1,0,0.413793103448276;0,0.448275862068966,0.413793103448276;0.448275862068966,0,0.103448275862069;1,0.758620689655172,0.379310344827586]; %JochenK
for nTrack=1:length(KymoTrackObj)
    if isempty(KymoTrackObj(nTrack).Tags) || ~KymoTrackObj(nTrack).Visible
        continue
    end
    switch direction(nTrack)
        case 1
            aligntag='left';
            before='  ';
            after='';
        case 0
            aligntag='center';
            before='';
            after='';
        case -1
            aligntag='right';
            before='';
            after='  ';
    end
    tags=KymoTrackObj(nTrack).Tags(ismember(KymoTrackObj(nTrack).ObjFrames,intersect(KymoTrackObj(nTrack).ObjFrames,KymoTrackObj(nTrack).Track(:,1))));
    if tagcol>4
        symbol='x';
    else
        symbol='-';
    end
    for m=1:length(tags)
        if tags(m)>0
            KymoTrackObj(nTrack).PlotHandles(1+m,1) = text(KymoTrackObj(nTrack).Track(m,2),KymoTrackObj(nTrack).Track(m,1),[before symbol after],'Color',colors(tags(m),:), 'VerticalAlignment','middle', 'HorizontalAlignment', aligntag);
        end
    end
    m=round(length(KymoTrackObj(nTrack).Track)/2);
    KymoTrackObj(nTrack).PlotHandles(end+1,1) = text(KymoTrackObj(nTrack).Track(m,2),KymoTrackObj(nTrack).Track(m,1),[before before before before before KymoTrackObj(nTrack).RefPos after after after after after],'Color',KymoTrackObj(nTrack).Color, 'VerticalAlignment','middle', 'HorizontalAlignment', aligntag);
end
