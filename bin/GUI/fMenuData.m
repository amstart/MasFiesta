function fMenuData(func,varargin)
try
switch func
    case 'ConnectObjects'
        ConnectObjects(varargin{1});
    case 'LoadLink'
        LoadLink;
    case 'SaveLink'
        SaveLink;
    case 'LoadFolder'
        LoadFolder(varargin{:});
    case 'OpenStack'
        OpenStack(varargin{:});
    case 'OpenStackSpecial'
        OpenStackSpecial(varargin{:});
    case 'LoadStack'
        LoadStack; 
    case 'SaveStack'
        SaveStack; 
    case 'CloseStack'
        CloseStack(varargin{1});
    case 'LoadTracks'
        LoadTracks(varargin{:});
    case 'ImportTracks'
        ImportTracks(varargin{1});        
    case 'SaveTracks'
        SaveTracks(varargin{1}); 
    case 'SaveText'
        SaveText(varargin{1});         
    case 'ClearTracks'
        ClearTracks(varargin{1}); 
    case 'LoadObjects'
        LoadObjects(varargin{1});  
    case 'SaveObjects'
        SaveObjects(varargin{1});          
    case 'ClearObjects'
        ClearObjects(varargin{1});          
    case 'Export'
        Export(varargin{1});          
end
catch ME
    fMsgDlg({'FIESTA detected a problem during analysis','Error message:','',getReport(ME,'extended','hyperlinks','off')},'error');    
end

function OpenMetaData()
OpenFile = [tempdir 'FIESTA_metadata.xml'];
if isunix
    system(['open ' OpenFile]);
else
    winopen(OpenFile);
end

function OpenStack(hMainGui, reopen)
global Stack;
global TimeInfo;
global Config;
global Molecule;
global Filament;
global FiestaDir;
Config.Mode= 'Single';
set(hMainGui.MidPanel.pNoData,'Visible','on')
set(hMainGui.MidPanel.tNoData,'String','Loading Stack...','Visible','on');
set(hMainGui.MidPanel.pView,'Visible','off');
if reopen == 0  %JochenK
    [FileName,PathName] = uigetfile({'*.stk;*.nd2;*.zvi;*.tif;*.tiff','Image Stacks (*.stk,*.nd2,*.zvi,*.tif,*.tiff)'},'Select the Stack',FiestaDir.Stack, 'MultiSelect', 'on'); %open dialog for *.stk files
else
    names = Config.StackName;
    names = names(~cellfun(@(x) strcmp(x,'~'), names));
    FileName = names{1};
    PathName = Config.Directory{1};
end
if PathName~=0
    %try
%         reader = bfGetReader([PathName FileName]);
%     	OMEdata = reader.getMetadataStore();
%         seriesMetadata = reader.getSeriesMetadata();
%         globalMetadata = reader.getGlobalMetadata();
%         javaMethod('merge', 'loci.formats.MetadataTools', ...
%                globalMetadata, seriesMetadata, 'Global ');
%         tmp = char(seriesMetadata);
%         tmp = strsplit(tmp, ',');
%         metaforall = cellfun(@(s) isempty(strfind(s, '#')), tmp);
%         tmp = tmp(metaforall);
%         Config.meta.exposure = tmp(cellfun(@(s) ~isempty(strfind(s, 'Global Exposure=')), tmp));
%         Config.meta.laserpower = tmp(cellfun(@(s) ~isempty(strfind(s, 'Global m_dMultiLaserLinePower')), tmp));
%         Config.meta.laserstatus = tmp(cellfun(@(s) ~isempty(strfind(s, 'Global m_bMultiLaser_LineUsedLineUsed')), tmp));
%         fid = fopen([tempdir 'FIESTA_OME.xml'], 'wt','n', 'UTF-8');
%         fprintf(fid, '%s', OMEdata);
%         fclose(fid);
    %catch
    %end
    Time = NaN;
    PixSize = [];
    try
        if strcmpi(FileName(end-3:end),'.stk')
            filetype = 'MetaMorph';
        elseif strcmpi(FileName(end-3:end),'.nd2')
            filetype = 'ND2';
        elseif strcmpi(FileName(end-3:end),'.zvi')
            filetype = 'ZVI';
        else
            filetype = 'TIFF';
        end
    catch
        filetype = 'multiple files';
    end
    set(hMainGui.fig,'Pointer','watch');   
    CloseStack(hMainGui);
    hMainGui=getappdata(0,'hMainGui');
    failed=0;
    FiestaDir.Stack=PathName;
    if strcmp(get(hMainGui.Menu.mSaveLoadDir,'Checked'),'on') %JochenK
        underscores = strfind(FileName, '_');
        if ~isempty(underscores) && exist([FiestaDir.Stack FileName(1:underscores(1)-1)], 'dir')
            FiestaDir.Load = [FiestaDir.Stack FileName(1:underscores(1)-1)];
            FiestaDir.Save = [FiestaDir.Stack FileName(1:underscores(1)-1)];
        elseif isempty(strfind(FiestaDir.Load, FiestaDir.Stack))
            FiestaDir.Load = FiestaDir.Stack;
            FiestaDir.Save = FiestaDir.Stack;
        end
    end
    try
        if iscell(FileName)
            N = length(FileName);
        else
            f=[PathName FileName];
            N = 1;
        end
        start = 1;
        for n = 1:N
            if iscell(FileName)
                f=[PathName FileName{n}];
            end
            bfdata = bfopen(f);
            stackfile = bfdata{1};
            stackfile = stackfile(:,1);
            for i = start:length(stackfile)+start-1
                index = i-start+1;
                Stack{1}(:,:,i) = stackfile{index};
            end
            omeMeta = bfdata{1, 4};
            try
                PixSize = double(omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.NANOMETER));
            catch
                PixSize = [];
            end
            try
                for i = start:length(stackfile)+start-1
                    index = i-start+1;
                    TimeInfo{1}(i) = double(omeMeta.getPlaneDeltaT(0,index-1).value(ome.units.UNITS.MILLISECOND));
                end
            catch
                TimeInfo{1} = [];
            end
            start = i+1;
        end
        if iscell(FileName)
            FileName = [FileName{:}];
        end
%         if strcmp(filetype,'ND2')||strcmp(filetype,'ZVI')
%             [Stack,TimeInfo,PixSize]=fReadND2(f); 
%         else
%             [Stack,TimeInfo,PixSize]=fStackRead(f);
%         end
    catch ME   
        fMsgDlg(ME.message,'error');
        failed=1;
    end
    if isempty(TimeInfo{1}) || length(unique(TimeInfo{1}))<length(TimeInfo{1})  
        Time = str2double(fInputDlg('No creation time  - Enter plane time difference in ms:','100'));    
        if ~isnan(Time)
            nFrames=size(Stack{1},3);
            TimeInfo{1}=(0:nFrames-1)*max(Config.Time);
        end
    end
    if isempty(PixSize)
        PixSize = str2double(fInputDlg('Enter Pixel Size in nm:','100'));    
    else
        PixSize = str2double(fInputDlg('Enter Pixel Size in nm:',num2str(PixSize,4)));    
    end
    if failed==0&&~isempty(Stack)
        set(hMainGui.fig,'Name',[hMainGui.Name ': ' FileName]);
        Config.StackName={FileName};
        Config.Directory={PathName};
        hMainGui.Directory.Stack={PathName};
        Config.StackType={filetype};
        Config.StackReadOptions = [];
        Config.PixSize=PixSize;
        Config.Time=Time;
        hMainGui.Values.TformChannel{1} = [1 0 0; 0 1 0; 0 0 1];
        hMainGui.Values.PixSize=Config.PixSize;
        hMainGui.Values.FrameIdx = [1 1];
        hMainGui.Values.MaxIdx = [1 size(Stack{1},3)];
        hMainGui.Values.PostSpecial = [];
        SetControls(hMainGui);
        fMainGui('InitGui',hMainGui);
    end
else
    if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
        set(hMainGui.MidPanel.pView,'Visible','on');
        set(hMainGui.MidPanel.tNoData,'Visible','off');        
        set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');    
    else
        set(hMainGui.MidPanel.pView,'Visible','off');
        set(hMainGui.MidPanel.tNoData,'Visible','on');        
        set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');    
    end
end
set(hMainGui.fig,'Pointer','arrow');

function SetControls(hMainGui)
setappdata(hMainGui.fig,'Drift', []);
setappdata(hMainGui.fig,'OffsetMap',[1 0 0;0 1 0;0 0 1]);
set(hMainGui.Menu.mCorrectStack,'Checked','off', 'Enable', 'off');
set(hMainGui.Menu.mAlignChannels,'Enable','off','Checked','off');
set(hMainGui.RightPanel.pTools.cKymoDrift,'Value',0);

function OpenStackSpecial(hMainGui, reopen)
global Stack;
global TimeInfo;
global Config;
global Molecule;
global Filament;
global FiestaDir;
if isfield(Config, 'Mode') && strcmp(Config.Mode, 'Single') && gcbo ~= hMainGui.Menu.mOpenStackSpecial %JochenK
    OpenStack(hMainGui, 1);
    return
end
set(hMainGui.MidPanel.pNoData,'Visible','on')
set(hMainGui.MidPanel.tNoData,'String','Loading Stack...','Visible','on');
set(hMainGui.MidPanel.pView,'Visible','off');
set(hMainGui.Menu.mAlignChannels,'Enable','off','Checked','off');
if isfield(Config, 'Mode') && reopen == 1 %JochenK
    fOpenStruct.Mode = Config.Mode;
    fOpenStruct.Optional = [];
    names = Config.StackName;
    names = names(~cellfun(@(x) strcmp(x,'~'), names));
    fOpenStruct.Data = cell(length(names),2);
    for i=1:length(names)
        fOpenStruct.Data{i,1} = names{i};    
        fOpenStruct.Data{i,2} = Config.Directory{i};
    end
else
    fOpenStruct = fOpenStackSpecial;
    Config.Mode = fOpenStruct.Mode;
end
if ~isempty(fOpenStruct)
    set(hMainGui.fig,'Pointer','watch');   
    CloseStack(hMainGui);
    Config.StackName = [];
    Config.Directory = [];
    hMainGui=getappdata(0,'hMainGui');
    if strcmp(fOpenStruct.Mode,'rSeparateFiles')
        nChannels = size(fOpenStruct.Data,1);
        Stack = cell(1,nChannels);
        TimeInfo = cell(1,nChannels);
        TformChannel = cell(1,nChannels);
        nFrames = zeros(1,nChannels);
        filetype = cell(1,nChannels);
        for n = 1:nChannels
            FileName = fOpenStruct.Data{n,1};
            PathName = fOpenStruct.Data{n,2};
            try
                if strcmpi(FileName(end-3:end),'.nd2')
                    [Stack(n),TimeInfo(n)]=fReadND2([PathName FileName]);
                else
                    [Stack(n),TimeInfo(n)]=fStackRead([PathName FileName]);
                end
            catch ME
                fMsgDlg(ME.message,'error');
                Stack = {};
                TimeInfo = {};
                break;
            end
            Config.StackName{n}=FileName;
            Config.Directory{n}=PathName;
            Config.StackReadOptions = [];
            nFrames(n)=size(Stack{n},3);
            if n>1
                ratio = length(Stack{n-1})/length(Stack{n});
                if ratio ~= 1
                    Stack{n} = imresize(Stack{n}, ratio);
                end
            end
            if (isempty(TimeInfo{n}) && nFrames>1) || length(unique(TimeInfo{n}))<length(TimeInfo{n}) 
                if nFrames(n) == 2
                    splitStack = questdlg('Only two frames here. Split into two channels? This will only work if you load this channel last.');
                    if strcmp(splitStack, 'Yes')
                        Stack{n+1} = Stack{n}(:,:,2);
                        Stack{n} = Stack{n}(:,:,1);
                        TimeInfo{n} = 0;
                        TimeInfo{n+1} = 0;
                        TformChannel{n+1} = [1 0 0; 0 1 0; 0 0 n+1];
                        Config.Time(n:n+1) = NaN;
                        nFrames(n:n+1) = 1;
                    end
                end
                if ~strcmp(splitStack, 'Yes')
                    Config.Time(n) = str2double(fInputDlg('Creation time corrupt - Enter plane time difference in ms:','100'));  
                    if ~isnan(Config.Time(n))
                        TimeInfo{n}=(0:nFrames-1)*Config.Time(n);
                    end  
                end
            else
                Config.Time(n) = NaN;
                if nFrames(n)==1
                    TimeInfo{n} = 0;
                end
            end
            if strcmpi(FileName(end-3:end),'.stk')
                filetype{n} = 'MetaMorph';
            elseif strcmpi(FileName(end-3:end),'.nd2')
                filetype{n} = 'ND2';
            elseif strcmpi(FileName(end-3:end),'.zvi')
                filetype{n} = 'ZVI';
            else
                filetype{n} = 'TIFF'; 
            end
            TformChannel{n} = [1 0 0; 0 1 0; 0 0 n];
        end
    else
        if strcmp(fOpenStruct.Mode,'rSequentialSplitting')
            nChannels = fOpenStruct.Data{3};
            mode = flipud(cell2mat(fOpenStruct.Data{4}));
            if mode(1)
                block(1:nChannels) = 1;
            else
                block = str2double(fOpenStruct.Data{5});
                block(nChannels+1:end) =[];
                if isnan(block(end))
                    block(end)=Inf;
                end
            end
            region = [];
        else
            region = {};
            mode = flipud(cell2mat(fOpenStruct.Data{3}));
            if mode(1)
                region{1} = [1 0.5];
                region{2} = [1 1];
            elseif mode(2)         
                region{1} = [0.5 1];
                region{2} = [1 1];
            elseif mode(3)
                region{1} = [0.5 0.5];
                region{2} = [0.5 1];
                region{3} = [1 0.5];
                region{4} = [1 1];
            elseif mode(4)
                region{1} = [1 0.25];
                region{2} = [1 0.5];
                region{3} = [1 0.75];
                region{4} = [1 1];
            elseif mode(5)
                region{1} = [1 0.25];
                region{2} = [1 0.5];
                region{3} = [1 0.75];
                region{4} = [1 1];
            end
            block = 1;
        end
        FileName = fOpenStruct.Data{1};
        PathName = fOpenStruct.Data{2};
        options.Block = block;
        options.Region = region;
        try
            if strcmpi(FileName(end-3:end),'.nd2')
                [Stack,TimeInfo]=fReadND2([PathName FileName],options);
            else
                [Stack,TimeInfo]=fStackRead([PathName FileName],options);
            end
        catch ME
            fMsgDlg(ME.message,'error');
            Stack = {};
            TimeInfo = {};
        end
        if ~isempty(Stack)
            nChannels = length(TimeInfo);
            TformChannel = cell(1,nChannels);
            nFrames = zeros(1,nChannels);
            for n = 1:nChannels
                nFrames(n) = size(Stack{n},3);
            end
            Config.Directory{1}=PathName;
            Config.StackName{1}=FileName;
            Config.StackReadOptions = options;
            if strcmpi(FileName(end-3:end),'.stk')
                filetype{1} = 'MetaMorph';
                Config.Time(1:nChannels) = NaN;
            elseif strcmpi(FileName(end-3:end),'.nd2')
                filetype{1} = 'ND2';
                Config.Time(1:nChannels) = NaN;
            else
                if any(nFrames>1)
                    Config.Time(1:nChannels) = str2double(fInputDlg('Enter plane time difference in ms:','100'));
                else
                    Config.Time(1:nChannels) = 0;
                end
                filetype{1} = 'TIFF'; 
            end
            for n = 1:nChannels
                nFrames(n) = size(Stack{n},3);
                if isempty(TimeInfo{n}) || length(unique(TimeInfo{n}))<length(TimeInfo{n})   
                    Config.Time(n) = str2double(fInputDlg('Creation time corrupt - Enter plane time difference in ms:','100'));    
                end    
                if ~isnan(Config.Time(n))             
                   TimeInfo{n}=(0:nFrames(n)-1)*Config.Time(n);
                end 

                TformChannel{n} = [1 0 0; 0 1 0; 0 0 n];
            end
            if strcmp(fOpenStruct.Mode,'rSpatialSplitting')
                MaxImg1 = max(Stack{1},[],3);
                IC = MaxImg1;
                IR = MaxImg1(17:end-16,17:end-16);
                [optimizer,metric] = imregconfig('multimodal');
                TformChannel{1} = [1 0 0; 0 1 0; 0 0 1];
                for n = 2:nChannels
                    MaxImg2 = max(Stack{n},[],3);
                    I = MaxImg2(17:end-16,17:end-16);
                    c = normxcorr2(I,IC);
                    [ypeak, xpeak] = find(c==max(c(:)));
                    yoffSet = ypeak-size(I,1)-16;
                    xoffSet = xpeak-size(I,2)-16;
                    T = affine2d([ 1 0 0; 0 1 0; xoffSet yoffSet 1]); 
                    tform = imregtform(I,IR,'rigid',optimizer,metric,'InitialTransformation',T);
                    T = tform.T;
                    TformChannel{n} = T;
                    set(hMainGui.Menu.mAlignChannels,'Enable','on');
                end
            end
        end
    end
    FiestaDir.Stack=PathName;
    if strcmp(get(hMainGui.Menu.mSaveLoadDir,'Checked'),'on') %JochenK
        underscores = strfind(FileName, '_');
        if exist([FiestaDir.Stack FileName(1:underscores(1)-1)], 'dir')
            FiestaDir.Load = [FiestaDir.Stack FileName(1:underscores(1)-1)];
            FiestaDir.Save = [FiestaDir.Stack FileName(1:underscores(1)-1)];
        elseif isempty(strfind(FiestaDir.Load, FiestaDir.Stack))
            FiestaDir.Load = FiestaDir.Stack;
            FiestaDir.Save = FiestaDir.Stack;
        end
    end
    if ~isempty(Stack)
        n = length(nFrames);
        if n>1
            if all(nFrames==nFrames(1))
                hMainGui.Values.FrameIdx = ones(1,2); 
                hMainGui.Values.MaxIdx = [n nFrames(1)];
            else
                hMainGui.Values.FrameIdx = ones(1,n+1); 
                hMainGui.Values.MaxIdx = [n nFrames];
            end
        end
        PixSize = str2double(fInputDlg('Enter Pixel Size in nm:','100'));
        Config.PixSize=PixSize;
        Config.StackType=filetype;
        hMainGui.Values.PixSize=Config.PixSize;
        hMainGui.Values.TformChannel = TformChannel;
        hMainGui.Values.PostSpecial = fOpenStruct.Optional;
        SetControls(hMainGui);
        fMainGui('InitGui',hMainGui);
    end
end
if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.tNoData,'Visible','off');        
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');    
else
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'Visible','on');        
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');    
end
set(hMainGui.fig,'Pointer','arrow');
 
function SaveStack
global Stack;
global TimeInfo; %#ok<NUSED>
global FiestaDir
if length(Stack)>1
    answer = inputdlg('Channel? (Note: Do not overwrite your original data, you will lose metadata)', 'Enter Channel #', 1, {'1'});
    channel = str2double(answer);
else
    channel = 1;
end
[FileName,PathName,FilterSpec] = uiputfile({'*.tif','Multilayer TIFF-Files (*.tif)';'*.mat','MATLAB-File (*.mat)'},'Save Stack',FiestaDir.Stack); %open dialog for *.stk files 
if FileName~=0
    if FilterSpec==1
        file = [PathName FileName];
        if isempty(strfind(file,'.tif'))
            file = [file '.tif'];
        end
        bfsave(Stack{channel},file,'BigTiff', true, 'dimensionOrder', 'XYTCZ');
    else
        progressdlg('Title','Saving Stack','String','Writing stack to MATLAB file','Indeterminate','on');
        file = [PathName FileName];
        if isempty(strfind(file,'.mat'))
            file = [file '.mat'];
        end
        save(file,'Stack','TimeInfo');
        progressdlg('close');
    end
end

function LoadStack
global Stack;
global TimeInfo; %#ok<NUSED>
global FiestaDir;
global Config;
hMainGui = getappdata(0,'hMainGui');
[FileName,PathName] = uigetfile({'*.mat','MATLAB Stacks (*.mat)'},'Select the Stack',FiestaDir.Stack); %open dialog for *.stk files
if FileName~=0
    progressdlg('Title','Loading Stack','String','Reading stack from MATLAB file','Indeterminate','on');
    load([PathName FileName]); 
    progressdlg('close');
    PixSize = str2double(fInputDlg('Enter Pixel Size in nm:','100'));
    nFrames = zeros(size(Stack));
    TformChannel = cell(size(Stack));
    for n = 1:length(Stack)
        nFrames(n) = size(Stack{n},3);
        TformChannel{n} = [1 0 0; 0 1 0; 0 0 1];
    end 
    if all(nFrames==nFrames(1))
        hMainGui.Values.FrameIdx = ones(1,2); 
        hMainGui.Values.MaxIdx = [n nFrames(1)];
    else
        hMainGui.Values.FrameIdx = ones(1,n+1); 
        hMainGui.Values.MaxIdx = [n nFrames];
    end
    Config.PixSize=PixSize;
    Config.StackType='matlab';
    Config.StackName={FileName};
    Config.Directory={PathName};
    hMainGui.Values.PixSize=Config.PixSize;
    hMainGui.Values.TformChannel = TformChannel;
    hMainGui.Values.PostSpecial = [];
    SetControls(hMainGui);
    fMainGui('InitGui',hMainGui);
end
if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.tNoData,'Visible','off');        
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');    
else
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'Visible','on');        
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');    
end
    
function CloseStack(hMainGui)
global Stack;
global TimeInfo;
global Molecule;
global Filament;
global Config;
if ~isempty(Stack)
    hMainGui=DeleteAllRegions(hMainGui);    
    set(hMainGui.MidPanel.sFrame,'Enable','off');
    set(hMainGui.MidPanel.eFrame,'Enable','off','String','');  
    set(hMainGui.fig,'Name',hMainGui.Name);
    fRightPanel('AllToolsOff',hMainGui);
    fLeftPanel('DisableAllPanels',hMainGui);
    hMainGui=getappdata(0,'hMainGui');
    fShared('DeleteScan',hMainGui);
    hMainGui=getappdata(0,'hMainGui');
    hMainGui.Measure=[];
    hMainGui.Plots.Measure=[];
    hMainGui.Values.PixSize=Config.PixSize;
    hMainGui.Values.FrameIdx = [1 1];
    hMainGui.Values.MaxIdx = [1 1];
    hMainGui.Values.PostSpecial = [];
    set(hMainGui.ToolBar.ToolChannels,'Visible','off','State','off');
    set(hMainGui.ToolBar.ToolColors,'Visible','off');
    try
        delete(hMainGui.Image);
    catch
    end
    hMainGui.Image=[];
    hMainGui.Value.PixSize=1;
    delete(findobj('Parent',hMainGui.MidPanel.aView,'Tag','pObjects'));
    if isempty(Molecule)&&isempty(Filament)
        set(hMainGui.MidPanel.pView,'Visible','Off');
        set(hMainGui.MidPanel.pNoData,'Visible','On');
        set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');          
    end
    Stack={};
    TimeInfo={};
    Config.StackName=[];
    setappdata(0,'hMainGui',hMainGui);
    fShared('UpdateMenu',hMainGui);   
    fShow('Tracks');
end

function hMainGui=DeleteAllRegions(hMainGui)
nRegion=length(hMainGui.Region);
for i=nRegion:-1:1
    hMainGui.Region(i)=[];
    try
        delete(hMainGui.Plots.Region(i));
        hMainGui.Plots.Region(i)=[];
    catch
    end
end
fLeftPanel('RegUpdateList',hMainGui);

function LoadFolder(hMainGui)
persistent answer
if isempty(answer)
    answer = {''};
end
answer = inputdlg('What pattern should the filenames contain (only .mat files are looked for)?', 'Filenames', 1, answer);
LoadDir = fShared('GetLoadDir');
folder = uigetdir(LoadDir, 'Select the folder');
if folder~=0
    fileList = getAllFiles(folder);
    fileList = fileList(~cellfun(@isempty, strfind(fileList, '.mat'))); %only mat files
    fileList = fileList(~cellfun(@isempty, strfind(fileList, answer))); %only with pattern
    numfiles = length(fileList);
    progressdlg('String','Loading Files','Min',0,'Max',numfiles,'Parent',hMainGui.fig);
    for i = 1:numfiles
        [PathName, FileName, ext] = fileparts(char(fileList(i)));
        LoadTracks(hMainGui, [filesep FileName ext],PathName);
        progressdlg(i);
    end
end


function LoadTracks(varargin)
global Stack
global Molecule;
global Filament;
global Config;
if nargin == 1
    hMainGui=varargin{1};
else
    hMainGui=getappdata(0,'hMainGui');
end
fRightPanel('CheckDrift',hMainGui);
Mode=get(gcbo,'UserData');
set(hMainGui.MidPanel.pNoData,'Visible','on')
set(hMainGui.MidPanel.tNoData,'String','Loading Data...','Visible','on');
set(hMainGui.MidPanel.pView,'Visible','off');
if nargin<2
    if strcmp(Mode,'local')
        LoadDir = fShared('GetLoadDir');
    else
        DirServer = fShared('CheckServer');
        if ~isempty(DirServer)
            LoadDir = [DirServer 'Data' filesep];
        else
            return;
        end
    end
    [FileName, PathName] = uigetfile({'*.mat','FIESTA Data(*.mat)'},'Load FIESTA Tracks',LoadDir,'MultiSelect','on');
    if ~iscell(FileName)
        FileName={FileName};
    end
else
    FileName = varargin(1);
    PathName = varargin{2};
end
if PathName~=0
    set(hMainGui.fig,'Pointer','watch');
    if strcmp(Mode,'local')
       fShared('SetLoadDir',PathName);
    end
    FileName = sort(FileName);
    progressdlg('String',['Loading file 1 of ' num2str(length(FileName)) '...'],'Min',0,'Max',length(FileName),'Parent',hMainGui.fig);
    for n = 1 : length(FileName)
        ME = fLoad([PathName FileName{n}],'ME');
        if isempty(ME)
            tempMicrotubule=[];
            [tempMolecule,tempFilament]=fLoad([PathName FileName{n}],'Molecule','Filament');
            if isempty(tempMolecule)&&isempty(tempFilament)
                [tempMolecule,tempFilament,tempMicrotubule]=fLoad([PathName FileName{n}],'sMolecule','sFilament','sMicrotubule');
            end

            if isstruct(tempMicrotubule)&&~isstruct(tempFilament)
                tempFilament=tempMicrotubule;
            end
            if isempty(tempMolecule) && isempty(tempFilament) 
                fMsgDlg({['No tracks in ' FileName{n}],'Check configuration or reconnect objects'},'error');   
            else
                if ~isfield(tempFilament,'Data') && ~isfield(tempFilament,'data')
                    fMsgDlg(['Data in ' FileName{n} ' not compatible with FIESTA - try to Import Data'],'warn');
                else
                    if ~isempty(tempMolecule)
                        tempMolecule = set_loaded_from(tempMolecule, PathName, FileName{n}); %JochenK
                        tempMolecule = fDefStructure(tempMolecule,'Molecule');
                        Molecule = [Molecule tempMolecule]; %#ok<AGROW>
                    end
                    if ~isempty(tempFilament)
                        tempFilament = set_loaded_from(tempFilament, PathName, FileName{n}); %JochenK
                        tempFilament = fDefStructure(tempFilament,'Filament');
                        Filament = [Filament tempFilament]; %#ok<AGROW>
                    end
                end
            end
        else
            fMsgDlg({'FIESTA detected a problem during analysis','',['File: ' FileName{n}(1:end-21)],'','','Error message:','',getReport(ME,'extended','hyperlinks','off')},'error');
        end
        progressdlg(n,['Loading file ' num2str(n) ' of ' num2str(length(FileName)) '...']);
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
    fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK
    hMainGui.ZoomView.level = [];
    setappdata(0,'hMainGui',hMainGui);
    fShared('UpdateMenu',hMainGui);        
    fShow('Image');
    fShow('Tracks');
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');      
end
if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');      
    drawnow expose
else
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');      
end
set(hMainGui.fig,'Pointer','arrow');    

function Objects = set_loaded_from(Objects, PathName, FileName)
for i = 1:length(Objects)
    Objects(i).Custom.LoadedFromPath = PathName;
    Objects(i).Custom.LoadedFromFile = FileName;
end

function LoadLink()
LoadDir = fShared('GetLoadDir');
[FileName, PathName] = uigetfile({'*.mat','FIESTA Data(*.mat)'},'Load Link File',LoadDir);
fJKLoadLink(FileName, PathName, @LoadTracks)

function SaveLink()
global Molecule;
global Filament;
persistent SaveWarning
if isempty(SaveWarning)
    CreateStruct.WindowStyle = 'modal';
    CreateStruct.Interpreter = 'None';
    questdlg('This will not save your actual data but just a shortcut of your currently open files (this won''t show again in this session)!', 'Careful', 'Ok', 'Don''t worry');
    SaveWarning = 1;
end
LoadedFromFile = cell(length(Molecule) + length(Filament),1);
LoadedFromPath = cell(length(Molecule) + length(Filament),1);
for i = 1:length(Molecule)
    LoadedFromPath{i} = Molecule(i).Custom.LoadedFromPath;
    LoadedFromFile{i} = Molecule(i).Custom.LoadedFromFile;
end
for i = 1:length(Filament)
    LoadedFromPath{i+length(Molecule)} = Filament(i).Custom.LoadedFromPath;
    LoadedFromFile{i+length(Molecule)} = Filament(i).Custom.LoadedFromFile;
end
tmp = cell(size(LoadedFromFile));
for i = 1:length(LoadedFromFile)
    tmp{i} = [LoadedFromPath{i} LoadedFromFile{i}];
end
[~, id, ~] = unique(tmp);
LoadedFromFile = LoadedFromFile(id);
LoadedFromPath = LoadedFromPath(id);
try
    [FileName, PathName] = uiputfile({'*.mat','MAT-File (*.mat)';},'Save Links' ,fShared('GetSaveDir'));
catch
    [FileName, PathName] = uiputfile({'*.mat','MAT-File (*.mat)';},'Save Links');
end
if FileName~=0
    file = [PathName FileName];
    if isempty(strfind(file,'.mat'))
        file = [file '.mat'];
    end
    save(file,'LoadedFromFile', 'LoadedFromPath');
    try
        fShared('SetSaveDir',PathName);
    catch
    end
end
    
function ImportTracks(hMainGui)
global Molecule;
global Filament;
global Objects;
global Stack; x
fRightPanel('CheckDrift',hMainGui);
set(hMainGui.MidPanel.pNoData,'Visible','on')
set(hMainGui.MidPanel.tNoData,'String','Loading Data...','Visible','on');
set(hMainGui.MidPanel.pView,'Visible','off');
[FileName, PathName] = uigetfile({'*.mat','FOTS Data(*.mat)'},'Import FOTS Tracks',fShared('GetLoadDir'));    
if FileName~=0
    set(hMainGui.fig,'Pointer','watch');
    fShared('SetLoadDir',PathName);
    Objects=[];
    [sMolecule,sMicrotubule]=fLoad([PathName FileName],'sMolecule','sMicrotubule');
    nsMol=length(sMolecule);
    if nsMol>0
        sMolecule=fDefStructure(sMolecule,'Molecule');
        for i=1:nsMol
            sMolecule(i).Results(:,6)=sqrt(sMolecule(i).Results(:,8).^2+sMolecule(i).Results(:,9).^2)*2*sqrt(log(4));
            sMolecule(i).Results(:,8)=1;
            sMolecule(i).Results(:,9:end)=[];
        end
        sMolecule = [Molecule sMolecule];
        clear Molecule;
        Molecule = sMolecule;
        clear sMolecule;
    end
    sFilament=sMicrotubule;
    nsFil=length(sFilament);
    if nsFil>0
        sFilament=fDefStructure(sFilament,'Filament');
        for i=1:nsFil
            if size(sFilament(i).Results,2)==5
                for j=1:size(sFilament(i).Results,1)
                    MicX=sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,2);
                    MicY=sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,3);
                    f=1:1:length(MicX);
                    ff=1:0.01:length(MicX);
                    MicXX=spline(f,MicX,ff);
                    MicYY=spline(f,MicY,ff);
                    MicLenVec=sqrt( (MicXX(2:length(MicXX))-MicXX(1:length(MicXX)-1)).^2 +...
                                    (MicYY(2:length(MicYY))-MicYY(1:length(MicYY)-1)).^2);
                    MicLen=sum(MicLenVec);      
                    u=round(length(MicXX)/3);
                    while sum(MicLenVec(1:u))<MicLen/2
                        u=u+1;
                    end
                    sFilament(i).Results(j,3)=single(MicXX(u));
                    sFilament(i).Results(j,4)=single(MicYY(u));
                    sFilament(i).Results(j,6)=single(sum(MicLenVec));
                    sFilament(i).Data{j}(:,1) = single(sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,2));
                    sFilament(i).Data{j}(:,2) = single(sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,3));
                    sFilament(i).Data{j}(:,3) = single((sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,1)-1));
                    sFilament(i).Data{j}(:,4) = single(sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,7));
                    sFilament(i).Data{j}(:,6) = single(sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,4));
                    sFilament(i).Data{j}(:,5) = single(sFilament(i).Frame(sFilament(i).Results(j,1)).Positions(:,5));
                end
            end
            if (sFilament(i).Results(1,5)~=0)&&size(sFilament(i).Results,2)==6
                h=sFilament(i).Results(:,5);
                sFilament(i).Results(:,5)=single(sObject(i).Results(:,6));
                sFilament(i).Results(:,6)=single(h);
            end
            sFilament(i).PosCenter=sFilament(i).Results(:,3:4);
            sFilament(i).PosStart=sFilament(i).Results(:,3:4);
            sFilament(i).PosEnd=sFilament(i).Results(:,3:4);
        end
        sFilament = [Filament sFilament];
        clear Filament;
        Filament = sFilament;
        clear sFilament;
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
    fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK
    setappdata(0,'hMainGui',hMainGui);
    fShared('UpdateMenu',hMainGui)
    fShow('Image',hMainGui);
    fShow('Tracks',hMainGui);
    set(hMainGui.MidPanel.pView,'Visible','on');    
    set(hMainGui.MidPanel.pNoData,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');  
end
if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');  
    drawnow expose
end 
set(hMainGui.fig,'Pointer','arrow');
    
function SaveTracks(hMainGui)
global Molecule; 
global Filament; 
persistent SaveWithCustomField
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Tracks',fShared('GetSaveDir'));
if FileName ~= 0
    if isempty(SaveWithCustomField)
        SaveWithCustomField = questdlg('Save with the custom field (you will have to remove it manually if you want to open the file in vanilla FIESTA)?', 'Choice will be remembered', 'Yes','No','Yes' );
    end
    if ~isempty(strfind(get(gcbo,'UserData'),'select')) || strcmp(SaveWithCustomField, 'Yes')
        backup_Molecule = Molecule;
        backup_Filament = Filament;
    end
    if ~isempty(strfind(get(gcbo,'UserData'),'select'))
        Molecule([Molecule.Selected] ~= 1) = [];
        Filament([Filament.Selected] ~= 1) = [];
    end
    if strcmp(SaveWithCustomField, 'No')
        Molecule = rmfield(Molecule, 'Custom');
        Filament = rmfield(Filament, 'Custom');
    end
    set(gcf,'Pointer','watch');    
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Molecule','Filament','-v6');
    set(hMainGui.fig,'Pointer','arrow');    
    if ~isempty(strfind(get(gcbo,'UserData'),'select')) || strcmp(SaveWithCustomField, 'Yes')
        Molecule = backup_Molecule;
        Filament = backup_Filament;
    end
end

function SaveText(hMainGui)
global Molecule;
global Filament;
if ~isempty(strfind(get(gcbo,'UserData'),'select'))
    kMol = find([Molecule.Selected] == 1);
    kFil = find([Filament.Selected] == 1);
    Mode = strrep(get(gcbo,'UserData'),'select_','');
else
    kMol = 1:length(Molecule);
    kFil = 1:length(Filament);
    Mode = get(gcbo,'UserData');
end
if ~isempty(Molecule) || ~isempty(Filament)
    if strcmp(Mode,'multiple')
        PathName = uigetdir(fShared('GetSaveDir'));
    else
        [FileName, PathName] = uiputfile({'*.txt','Delimeted Text (*.txt)'}, 'Save FIESTA Tracks as...',fShared('GetSaveDir'));
        file = [PathName FileName];
        if isempty(findstr('.txt',file))
            file = [file '.txt'];
        end
    end
    if PathName~=0
        set(gcf,'Pointer','watch');        
        fShared('SetSaveDir',PathName);
        if strcmp(Mode,'single')
            file_id = fopen(file,'w');
        end
        for n = kMol
            if strcmp(Mode,'multiple')
                file = [PathName filesep Molecule(n).Name '.txt'];
                file_id = fopen(file,'w');
            end
            fprintf(file_id,'%s - %s - %s\n',Molecule(n).Name,Molecule(n).File,Molecule(n).Comments);
            if isempty(Molecule(n).PathData)
                PathData = [];
                PathHeader = '';
            else
                PathData = Molecule(n).PathData;
                PathHeader = sprintf('\tpath x-position[nm]\tpath y-position[nm]\tpath z-position[nm]\tdistance(along path)[nm]\tsideways(to path)[nm]\theight(to path)[nm]');
            end
            format = '%8f';
            %determine what kind of Molecule found
            if strcmp(Molecule(n).Type,'symmetric')
                fprintf(file_id,'frame\ttime[s]\tx-position[nm]\ty-position[nm]\tz-position[nm]\tdistance(to origin)[nm]\twidth(FWHM)[nm]\tamplitude[ABU]\tintensity(volume)[ABU]\tfit error of center[nm]%s\n',PathHeader);
                data = [Molecule(n).Results(:,1:8) 2*pi*(Molecule(n).Results(:,7)/Molecule(n).PixelSize/(2*sqrt(2*log(2)))).^2.*Molecule(n).Results(:,8) Molecule(n).Results(:,9) PathData];
            elseif strcmp(Molecule(n).Type,'stretched')
                fprintf(file_id,'frame\ttime[s]\tx-position[nm]\ty-position[nm]\tz-position[nm]\tdistance(to origin)[nm]\taverage width(FWHM)[nm]\tamplitude[ABU]\tfit error of center[nm]\twidth of major axis(FWHM)[nm]\twidth of minor axis(FWHM)[nm]\torientation(angle to x-axis)[rad]%s\n',PathHeader);
                data = [Molecule(n).Results(1:12) PathData];
            elseif strcmp(Molecule(n).Type,'ring1')
                fprintf(file_id,'frame\ttime[s]\tx-position[nm]\ty-position[nm]\tz-position[nm]\tdistance(to origin)[nm]\taverage width(FWHM)[nm]\tamplitude[ABU]\tfit error of center[nm]\tradius of ring[nm]\twidth of ring(FWHM)[nm]\tamplitude of ring[ABU]%s\n',PathHeader);
                data = [Molecule(n).Results(1:12) PathData];
            end
            for m = 2:size(data,2)
                format  = [format '\t%8f']; %#ok<AGROW>
            end
            format = [format '\n']; %#ok<AGROW>
            fprintf(file_id,format,data');
            fprintf(file_id,'\n');
            if strcmp(Mode,'multiple')
                fclose(file_id);
            end
        end
        for n = kFil
            if strcmp(Mode,'multiple')
                file = [PathName filesep Filament(n).Name '.txt'];
                file_id = fopen(file,'w');
            end
            fprintf(file_id,'%s - %s - %s\n',Filament(n).Name,Filament(n).File,Filament(n).Comments);
            if isempty(Filament(n).PathData)
                PathData = [];
                PathHeader = '';
            else
                PathData = Filament(n).PathData;
                PathHeader = sprintf('\tpath x-position[nm]\tpath y-position[nm]\tpath z-position[nm]\tdistance(along path)[nm]\tsideways(to path)[nm]\theight(to path)[nm]');
            end
            fprintf(file_id,'track data\n');
            format = '%8f';
            fprintf(file_id,'frame\ttime[s]\tx-position[nm]\ty-position[nm]\tz-position[nm]\tdistance(to origin)[nm]\tlength[nm]\taverage amplitude[ABU]\torientation(angle to x-axis)[rad]%s\n',PathHeader);
            data = [Filament(n).Results(1:9) PathData];
            for m = 2:size(data,2)
                format  = [format '\t%8f']; %#ok<AGROW>
            end
            format = [format '\n']; %#ok<AGROW>
            fprintf(file_id,format,data');
            fprintf(file_id,'\n');  
            
            for j=1:size(data,1)
                fprintf(file_id,'tracking details\n');
                fprintf(file_id,'frame\ttime[s]\tx-position[nm]\ty-position[nm]\tz-position[nm]\tdistance(to origin)[nm]\tlength[nm]\taverage amplitude[ABU]\torientation(angle to x-axis)[rad]%s\n',PathHeader);
                fprintf(file_id,format,data(j,:)');                
                fprintf(file_id,'x-position[nm]\ty-position[nm]\tz-position[nm]\tdistance to start[nm]\twidth(FWHM)[nm]\tamplitude[ABU]\tbackground[ABU]\n');
                fprintf(file_id,'%8f\t%8f\t%8f\t%8f\t%8f\t%8f\t%8f\n',Filament(n).Data{j}');
                fprintf(file_id,'\n');            
            end
            if strcmp(Mode,'multiple')
                fclose(file_id);
            end
        end
        if strcmp(Mode,'single')
            fclose(file_id);
        end
    end
end
set(hMainGui.fig,'Pointer','arrow');

function LoadObjects(hMainGui)
global Stack
global Objects;
global Molecule;
global Filament;
set(hMainGui.MidPanel.pNoData,'Visible','on')
set(hMainGui.MidPanel.tNoData,'String','Loading Data...','Visible','on');
set(hMainGui.MidPanel.pView,'Visible','off');
Mode = get(gcbo,'UserData');
if strcmp(Mode,'local')
    LoadDir = fShared('GetLoadDir');
else
    DirServer = fShared('CheckServer');
    if ~isempty(DirServer)
        LoadDir = [DirServer 'Data' filesep];
    else
        return;
    end
end
[FileName, PathName] = uigetfile({'*.mat','FIESTA Data(*.mat)'},'Load FIESTA Objects',LoadDir,'MultiSelect','on');    
if ~iscell(FileName)
    FileName={FileName};
end
if PathName~=0
    set(hMainGui.fig,'Pointer','watch');
    if strcmp(Mode,'local')
       fShared('SetLoadDir',PathName);
    end
    FileName = sort(FileName);
    progressdlg('String',['Loading file 1 of ' num2str(length(FileName)) '...'],'Min',0,'Max',length(FileName),'Parent',hMainGui.fig);
    for n = 1 : length(FileName)
        ME = fLoad([PathName FileName{n}],'ME');
        if ~isempty(ME)
        	fMsgDlg({'FIESTA detected a problem during analysis','',['File: ' FileName{n}(1:end-21)],'','','Error message:','',getReport(ME,'extended','hyperlinks','off')},'error');
        end
        tempObjects = fLoad([PathName FileName{n}],'Objects');
        if isempty(tempObjects)
            tempObjects = fLoad([PathName FileName{n}],'sObjects');
            if isempty(tempObjects)
                fMsgDlg(['No Objects detected in ' FileName{n}],'warn');     
            end
        end
        if ~isempty(tempObjects)
            tempObjects = fConvertObjects(tempObjects);
            for m=1:length(tempObjects)
                if m<=length(Objects)
                    if ~isempty(Objects{m}) 
                        if isempty(tempObjects{m})
                            tempObjects{m} = Objects{m};
                        else
                            name = fieldnames(Objects{m});
                            for k = 1:length(name)
                                if ~strcmp(name{k},'time')
                                    tempObjects{m}.(name{k}) = [Objects{m}.(name{k}) tempObjects{m}.(name{k})];
                                end
                            end
                        end
                    end
                end
            end
            Objects = tempObjects;
        end
        progressdlg(n,['Loading file ' num2str(n) ' of ' num2str(length(FileName)) '...']);
    end
    hMainGui.File=FileName{n};
    setappdata(0,'hMainGui',hMainGui);
    fShared('UpdateMenu',hMainGui);   
    if ~isempty(Stack)
        fShow('Image',hMainGui);
        set(hMainGui.MidPanel.pView,'Visible','on');
        set(hMainGui.MidPanel.pNoData,'Visible','off');
        set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');      
    end
end
if ~isempty(Stack)||~isempty(Molecule)||~isempty(Filament)
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','off');      
    drawnow expose
end    
set(hMainGui.fig,'Pointer','arrow');

    
function SaveObjects(hMainGui)
global Objects; %#ok<NUSED>
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Objects',fShared('GetSaveDir'));
if FileName~=0
    set(gcf,'Pointer','watch');
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Objects','-v6');
    set(hMainGui.fig,'Pointer','arrow');    
end

function ConnectObjects(hMainGui)
global Objects;
global Config;
global Stack;
global Filament;
global Molecule;
newConfig = Config;
newConfig.TformChannel = hMainGui.Values.TformChannel;
newConfig.TrackChannel = hMainGui.Values.FrameIdx(1);
fAnalyseStack(Stack,[],newConfig,nan,Objects)
% [Filament, Molecule] = fConnectObjects(Objects, newConfig, 0, Stack);
% fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
% fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK

function ClearObjects(hMainGui)
global Objects;
clear global Objects;
Objects = [];
hMainGui.File=[];
fShared('UpdateMenu',hMainGui);  
fShow('Image',hMainGui);