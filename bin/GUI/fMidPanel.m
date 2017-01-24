function fMidPanel(func,varargin)
switch func
    case 'sFrame'
        sFrame(varargin{:});
    case 'eFrame'
        eFrame(varargin{1});
    case 'Update'
        Update(varargin{1});
end

function Update(hMainGui)
global TimeInfo
idx = getFrameIdx;
if length(hMainGui.Values.FrameIdx)<3
    idx(1) = 1;
end
set(hMainGui.MidPanel.tInfoTime,'String',sprintf('Time: %0.3f s',(TimeInfo{idx(1)}(idx(2))-TimeInfo{idx(1)}(1))/1000));
setappdata(0,'hMainGui',hMainGui);
fShared('ReturnFocus');
fShow('Image');


function sFrame(hMainGui, varargin) %JochenK
global IsPlaying
CleaneSlidertime = regexprep(get(hMainGui.MidPanel.eSlidertime,'String'),'[\D]','');
CleaneSliderstep = regexprep(get(hMainGui.MidPanel.eSliderstep,'String'),'[\D]','');
set(hMainGui.MidPanel.eSlidertime,'String', CleaneSlidertime);
set(hMainGui.MidPanel.eSliderstep,'String', CleaneSliderstep);
if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end
if isempty(varargin)
    idx=round(get(hMainGui.MidPanel.sFrame,'Value'));
    IsPlaying = [];
else
    if nargin > 2 && ~isempty(IsPlaying) && IsPlaying == varargin{1}
        idx=hMainGui.Values.FrameIdx(n);
        IsPlaying = [];
    else
        IsPlaying = varargin{1};
        idx=hMainGui.Values.FrameIdx(n);
        step = varargin{1} * round(str2double(get(hMainGui.MidPanel.eSliderstep,'String')));
        idx = idx+step;
        if ~isnumeric(step) || ~isnumeric(str2double(get(hMainGui.MidPanel.eSlidertime,'String'))/1000)
            return
        end
        pause(str2double(get(hMainGui.MidPanel.eSlidertime,'String'))/1000);
        if isempty(IsPlaying)
            return
        end
    end
end
if idx<1
    hMainGui.Values.FrameIdx(n)=hMainGui.Values.MaxIdx(n);
elseif idx>hMainGui.Values.MaxIdx(n)
    hMainGui.Values.FrameIdx(n)=1; %JochenK
else
    hMainGui.Values.FrameIdx(n)=idx;
end
if get(hMainGui.MidPanel.cCoupleChannels, 'Value')
    NRest = setxor(n, 2:length(hMainGui.Values.FrameIdx));
    for nRest = NRest
        idx = round(hMainGui.Values.FrameIdx(n)*hMainGui.Values.MaxIdx(nRest)/hMainGui.Values.MaxIdx(n));
        hMainGui.Values.FrameIdx(nRest) = min(max(idx,1),hMainGui.Values.MaxIdx(nRest));
    end
end
hMainGui.Values.FrameIdx = real(hMainGui.Values.FrameIdx);
set(hMainGui.MidPanel.eFrame,'String',int2str(hMainGui.Values.FrameIdx(n)));
setappdata(0,'hMainGui',hMainGui);
Update(hMainGui);
if ~isempty(varargin) && ~isempty(IsPlaying)
    hMainGui=getappdata(0,'hMainGui');
    set(hMainGui.MidPanel.sFrame,'Value',hMainGui.Values.FrameIdx(n));
    sFrame(hMainGui, varargin{1});
end


function eFrame(hMainGui)
CleaneFrame = regexprep(get(hMainGui.MidPanel.eFrame,'String'),'[\D]','');
set(hMainGui.MidPanel.eFrame,'String', CleaneFrame);
try
    idx=round(str2double(get(hMainGui.MidPanel.eFrame,'String')));
catch
end
if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end
if idx<1
    hMainGui.Values.FrameIdx(n)=1;
elseif idx>hMainGui.Values.MaxIdx(n)
    hMainGui.Values.FrameIdx(n)=hMainGui.Values.MaxIdx(n);
elseif ~isnan(idx)
    hMainGui.Values.FrameIdx(n)=idx;
end
if get(hMainGui.MidPanel.cCoupleChannels, 'Value') %JochenK
    NRest = setxor(n, 2:length(hMainGui.Values.FrameIdx));
    for nRest = NRest
        idx = round(hMainGui.Values.FrameIdx(n)*hMainGui.Values.MaxIdx(nRest)/hMainGui.Values.MaxIdx(n));
        hMainGui.Values.FrameIdx(nRest) = min(max(idx,1),hMainGui.Values.MaxIdx(nRest));
    end
end
setappdata(0,'hMainGui',hMainGui);
set(hMainGui.MidPanel.eFrame,'String',int2str(hMainGui.Values.FrameIdx(n)));
set(hMainGui.MidPanel.sFrame,'Value',hMainGui.Values.FrameIdx(n));
Update(hMainGui);