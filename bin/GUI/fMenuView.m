function fMenuView(func,varargin)
switch func
    case 'View'
        View(varargin{1},varargin{2});
    case 'KeepFrames'
        KeepFrames(varargin{:});
    case 'ViewCheck'
        ViewCheck;
    case 'ColorOverlay'
        ColorOverlay;
    case 'CorrectStack'
        CorrectStack;
    case 'SplitIntoChannels'
        SplitIntoChannels(varargin{:});
end

function KeepFrames(hMainGui) %JochenK
global Stack
global TimeInfo
channel = hMainGui.Values.FrameIdx(1);
answer = fQuestDlg('Do you want to keep every nth frame or do you want to keep a block?', 'Mode', {'nth', 'block'}, 'nth');
answer2 = fQuestDlg('Move deleted frames to new channel?', 'New Channel', {'Yep', 'Nah'}, 'Yep');
if strcmp(answer2, 'Yep')
    keep = 1;
else
    keep = 0;
end
if strcmp(answer, 'nth')
    answer = fInputDlg({'Enter start of interval.','Enter step size (n).'},{1,2});
    start = str2double(answer{1});
    step = str2double(answer{2});
    if start == 1
        start2 = 2;
    else
        start2 = 1;
    end
    if keep
        Stack{end+1} = Stack{channel}(:,:, start2:step:end);
        TimeInfo{end+1} = TimeInfo{channel}(start2:step:end);
    end
    Stack{channel} = Stack{channel}(:,:, start:step:end);
    TimeInfo{channel} = TimeInfo{channel}(start:step:end);
else
    answer = fInputDlg({'Enter first and the last frames to keep in current channel (the others will be deleted for the session).','Enter last frame'},{int2str(1),int2str(hMainGui.Values.MaxIdx(channel+1))});
    firstframe = str2double(answer{1});
    lastframe = str2double(answer{2});
    if keep
        Stack{end+1} = Stack{channel}(:,:, [1:firstframe-1 lastframe+1:end]);
        TimeInfo{end+1} = TimeInfo{channel}(:,:, [1:firstframe-1 lastframe+1:end]);
    end
    Stack{channel} = Stack{channel}(:,:, firstframe:lastframe);
    TimeInfo{channel} = TimeInfo{channel}(firstframe:lastframe);
end
hMainGui.Values.MaxIdx(channel+1) = length(TimeInfo{channel});
set(hMainGui.MidPanel.sFrame, 'Max', size(Stack{channel},3));
fMidPanel('eFrame',hMainGui)
setappdata(0,'hMainGui',hMainGui);
if keep
    hMainGui.Values.MaxIdx(end+1) = length(TimeInfo{end});
    hMainGui.Values.TformChannel{end+1} = [1 0 0; 0 1 0; 0 0 1];
    fMainGui('InitGui',hMainGui)
end

function SplitIntoChannels(hMainGui)
global Stack
global TimeInfo
for i=2:size(Stack{1},3)
    Stack{end+1} = Stack{1}(:,:,i);
    TimeInfo{end+1} = 0;
    hMainGui.Values.MaxIdx(i+1) = 1;
    hMainGui.Values.TformChannel{i+1} = [1 0 0; 0 1 0; 0 0 1];
end
hMainGui.Values.MaxIdx(1) = length(Stack);
Stack{1} = Stack{1}(:,:,1);
TimeInfo{1} = 0;
hMainGui.Values.MaxIdx(2) = 1;
fMainGui('InitGui',hMainGui)


function CorrectStack
global Stack;
global Config;
hMainGui = getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
button = fQuestDlg({'Please note: (i) will change the actual intensities of the Stack, (ii) will not be used for tracking (original Stack is opened), (iii) it can not be undone (reopen the original Stack)! Use this option only for displaying as well as exporting images, kymographs or movies.',...
                    'Which interpolation method should be used?'},'Choose Interpolation Method',{'Nearest(fast)','Linear(slow)'},'Nearest(fast)');
if strcmp(button,'Nearest(fast)')
    linear = 0;
elseif strcmp(button,'Linear(slow)')
    linear = 1;
else
    return;
end
for m = 1:length(Stack)
    if length(Drift)<m
        Drift{m} = [];
    end
%     if correct_first_frame
%         Stack{m} = cat(3, ones(size(Stack{m}(:,:,1))),Stack{m});
%     end
    if (m==1 && ~isempty(Drift{m})) || (m>1 && (~isempty(Drift{m}) || ~all(hMainGui.Values.TformChannel{1}(:)==hMainGui.Values.TformChannel{m}(:))))
        [y,x,z] = size(Stack{m}); 
        T = hMainGui.Values.TformChannel{m};
        X = repmat(1:x,y,1);
        Y = repmat(1:y,1,x);

        X = X(:);
        Y = Y(:);

        T = [ T(1,1) -T(1,2) 0; -T(2,1) T(2,2) 0; -T(3,1)*T(1,1)-T(3,2)*T(1,2) -T(3,2)*T(1,1)+T(3,1)*T(1,2) 1];
        
        TX = X * T(1,1) + Y * T(2,1) + T(3,1);
        TY = X * T(1,2) + Y * T(2,2) + T(3,2);
        
        progressdlg(['Correcting Stack (Channel ' num2str(m) ')']);
        if isempty(Drift{m})
            NX = TX;
            NY = TY;
            if linear
                k = NX<1 | NX>x | NY<1 | NY>y;
                NX(k) = [];
                NY(k) = [];
                X(k) = [];
                Y(k) = [];
                idx = Y + (X - 1).*y;
                NX1 = fix(NX);
                NX2 = ceil(NX);
                NY1 = fix(NY);
                NY2 = ceil(NY);
                idx11 = NY1 + (NX1 - 1).*y;
                idx12 = NY2 + (NX1 - 1).*y;
                idx21 = NY1 + (NX2 - 1).*y;
                idx22 = NY2 + (NX2 - 1).*y;
                W11=(NX2-NX).*(NY2-NY);
                W12=(NX2-NX).*(NY-NY1);
                W21=(NX-NX1).*(NY2-NY);
                W22=(NX-NX1).*(NY-NY1);
            else
                NX = round(NX);
                NY = round(NY);
                k = NX<1 | NX>x | NY<1 | NY>y;
                NX(k) = [];
                NY(k) = [];
                X(k) = [];
                Y(k) = [];
                idx = Y + (X - 1).*y;
                tidx = NY + (NX - 1).*y;
            end
            for n = 1:z   
                I = Stack{m}(:,:,n);
                if linear
                    NI = zeros(y,x);
                    I = double(I);
                    NI(idx) = I(idx11).*W11+...
                          I(idx21).*W21+...
                          I(idx12).*W12+...
                          I(idx22).*W22;
                    NI = uint16(NI);
                else
                    NI = zeros(y,x,'like',I);
                    NI(idx) = I(tidx);
                end
                Stack{m}(:,:,n) = NI;
                progressdlg(n/z*100);
            end
        else
            for n = 1:z  
                k=find(Drift{m}(:,1)==n);
                if isempty(k)
                    NX = TX;
                    NY = TY;
                else
                    NX = TX+Drift{m}(k,2)/Config.PixSize;
                    NY = TY+Drift{m}(k,3)/Config.PixSize;
                end
                Stack{m}(:,:,n) = QuickInterpol(Stack{m}(:,:,n),X,Y,NX,NY,linear);
                progressdlg(n/z*100);
            end
        end
        if ~isempty(Drift)
            set(hMainGui.RightPanel.pTools.cKymoDrift,'Value',1,'Enable','off');
        end
        set(hMainGui.Menu.mCorrectStack,'Checked','on', 'Enable','off');
        hMainGui.Values.TformChannel{m}=hMainGui.Values.TformChannel{1};
    end
    if strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on')
        Config.StackName = ['~' Config.StackName];
        fShared('UpdateMenu',hMainGui);        
        fShow('Image');
        fShow('Tracks');
    end
end

function NI = QuickInterpol(I,X,Y,NX,NY,linear)
[y,x] = size(I);
if linear
    k = NX<1 | NX>x | NY<1 | NY>y;
    NX(k) = [];
    NY(k) = [];
    X(k) = [];
    Y(k) = [];
    idx = Y + (X - 1).*y;
    I = double(I);
    NI = zeros(y,x);
    NX1 = fix(NX);
    NX2 = ceil(NX);
    NY1 = fix(NY);
    NY2 = ceil(NY);
    if all(NX1==NX2) && all(NX1==NX2) 
        NI = uint16(I);
    else
        idx11 = NY1 + (NX1 - 1).*y;
        idx12 = NY2 + (NX1 - 1).*y;
        idx21 = NY1 + (NX2 - 1).*y;
        idx22 = NY2 + (NX2 - 1).*y;
        W11=(NX2-NX).*(NY2-NY);
        W12=(NX2-NX).*(NY-NY1);
        W21=(NX-NX1).*(NY2-NY);
        W22=(NX-NX1).*(NY-NY1);
        NI(idx) = I(idx11).*W11+...
                  I(idx21).*W21+...
                  I(idx12).*W12+...
                  I(idx22).*W22;
        NI = uint16(NI);
    end
else
    NI = zeros(y,x,'like',I);
    NX = round(NX);
    NY = round(NY);
    k = NX<1 | NX>x | NY<1 | NY>y;
    NX(k) = [];
    NY(k) = [];
    X(k) = [];
    Y(k) = [];
    idx = Y + (X - 1).*y;
    tidx = NY + (NX - 1).*y;
    NI(idx) = I(tidx);
end

function View(hMainGui,idx)
n = getChIdx;
if ~isempty(idx)
   hMainGui.Values.FrameIdx(2:end)=real(hMainGui.Values.FrameIdx(2:end))+idx*1i;
else
   hMainGui.Values.FrameIdx(n) = round(get(hMainGui.MidPanel.sFrame,'Value')); 
   hMainGui.Values.FrameIdx(2:end) = real(hMainGui.Values.FrameIdx(2:end));
end
setappdata(0,'hMainGui',hMainGui);
fShow('Image');

function ViewCheck
if strcmp(get(gcbo,'Checked'),'on')==1
    set(gcbo,'Checked','off');
else
    set(gcbo,'Checked','on');
end
fShow('Image');

function ColorOverlay
hMainGui=getappdata(0,'hMainGui');
if strcmp(get(hMainGui.Menu.mColorOverlay,'Checked'),'on')
    s = 'off';
else
    s ='on';
end
set(hMainGui.ToolBar.ToolChannels(5),'State',s);
fToolBar('Overlay');