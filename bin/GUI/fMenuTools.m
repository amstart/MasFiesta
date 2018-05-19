function fMenuTools(func,varargin)
switch func
    case 'MeasureLine'
        MeasureLine(varargin{1});
    case 'MeasureSegLine'
        MeasureSegLine(varargin{1});
    case 'MeasureFreehand'
        MeasureFreehand(varargin{1});
    case 'MeasureRect'
        MeasureRect(varargin{1});       
    case 'MeasureEllipse'
        MeasureEllipse(varargin{1});
    case 'MeasurePolygon'
        MeasurePolygon(varargin{1});
    case 'ScanLine'
        ScanLine(varargin{1});
    case 'ScanSegLine'
        ScanSegLine(varargin{1});
    case 'ScanFreehand'
        ScanFreehand(varargin{1});      
    case 'ShowKymoGraph'
        ShowKymoGraph(varargin{1});   
    case 'ShowMissing'
        ShowMissing(varargin{1});  
    case 'JoinNearby'
        JoinNearby(varargin{1});  
end

function ShowMissing(hMainGui)
global Molecule
global Filament
if length(hMainGui.Values.FrameIdx)>2
    n = hMainGui.Values.FrameIdx(1)+1;
else
    n = 2;
end
allframes = 1:hMainGui.Values.MaxIdx(n);
trackedframes = [];
for i=1:length(Molecule)
    if Molecule(i).Selected
        trackedframes = vertcat(trackedframes, Molecule(i).Results(:,1));
    end
end
for i=1:length(Filament)
    if Filament(i).Selected
        trackedframes = vertcat(trackedframes, Filament(i).Results(:,1));
    end
end
uitable1 = dialog('WindowStyle','normal');
uitable('Parent', uitable1, 'Data',setxor(allframes, trackedframes)); drawnow;

function JoinNearby(hMainGui)
global Molecule
answer = inputdlg('Look for Molecules in which radius?');
NewSet = Molecule;
delete = false(1, length(Molecule));
handle = progressdlg('String','Looking for close Molecules','Min',0,'Max',length(Molecule),'Parent',hMainGui.fig);
aborted = false;
for i=1:length(Molecule)
    for j=1:length(Molecule)
        if i~=j && ~delete(i)
            p1 = mean(Molecule(i).Results(:,3:4),1);
            p2 = mean(Molecule(j).Results(:,3:4),1);
            if CalcDistance(p1,p2) < str2double(answer)
                NewResults = vertcat(Molecule(i).Results, Molecule(j).Results);
                if max(sum(NewResults(:,1)==NewResults(:,1)')) > 1
                    continue
                end
                NewSet(i).Results = sortrows(NewResults);
                delete(j) = true;
            end
        end
    end
    progressdlg(i);
    if isempty(handle)
        aborted = true;
        break
    end
end
NewSet(delete) = [];
if ~aborted
    Molecule = NewSet;
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);
fRightPanel('UpdateKymoTracks',hMainGui);
fShow('Image');
fShow('Tracks');

function MeasureLine(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bLine,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bLine,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureSegLine(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bSegLine,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bSegLine,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureFreehand(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bFreehand,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bFreehand,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureRect(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bRectangle,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bRectangle,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasureEllipse(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bEllipse,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bEllipse,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function MeasurePolygon(hMainGui)
fRightPanel('ToolsMeasurePanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bPolygon,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bPolygon,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanLine(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bLineScan,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bLineScan,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanSegLine(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.bSegLineScan,'Value',1);
hMainGui.CursorMode=get(hMainGui.RightPanel.pTools.bSegLineScan,'UserData');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ScanFreehand(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
hMainGui.CursorMode='normal';
fRightPanel('CreateFilamentScan',hMainGui);
hMainGui=getappdata(0,'hMainGui');
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);

function ShowKymoGraph(hMainGui)
fRightPanel('ToolsScanPanel',hMainGui);
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.RightPanel.pTools.cShowKymoGraph,'Value',1);
fRightPanel('ShowKymoGraph',hMainGui);
hMainGui.Values.CursorDownPos(:)=0;
setappdata(0,'hMainGui',hMainGui);
