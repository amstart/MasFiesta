function fJKDynamicFilamentsGui(func,varargin)
if nargin == 0 || any(ishandle(func))
    Create;
    return
end
switch func
    case 'SortFilaments'
        SortFilaments();
    case 'UpdatePlot'
        UpdatePlot;
    case 'DeletePlots'
        DeletePlots;
    case 'Create'
        Create(varargin{:});
    case 'SetTable'
        SetTable;           
    case 'SetMenu'
        SetMenu(varargin{:}); 
    case 'Save'
        Save;   
    case 'keyPress'
        keyPress(varargin);
    case 'Load'
        Load(varargin{:});
    case 'LoadFolder'
        LoadFolder(varargin{:});
    case 'Delete'
        Delete;
    case 'Legend'
        Legend;   
    case 'ChoosePlot'
        ChoosePlot(varargin{:});
    case 'Export'
        Export;   
    case 'Update'
        Update;  
    case 'Draw'
        Draw(varargin{:});
    case 'Quicksave'
        Quicksave(varargin{:});
    case 'OpenInfo'
        OpenInfo;
    case 'OpenProtocol'
        OpenProtocol;
    case 'Select'
        Select;
    case 'Workspace'
        Workspace;
    case 'SurfPlot'
        SurfPlot;
    case 'CustomPlot'
        CustomPlot;
end

function Create(varargin)
global CurrentDir
if nargin == 0
    h=findobj('Tag','hDynamicFilamentsGui');
    close(h)

    hDynamicFilamentsGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','on','IntegerHandle','off','Name','Average Velocity',...
                          'NumberTitle','off','Position',[0.1 0.1 0.8 0.8],'HandleVisibility','callback','Tag','hDynamicFilamentsGui',...
                          'Visible','off','Resize','on','Renderer', 'painters');

    if ispc
        set(hDynamicFilamentsGui.fig,'Color',[236 233 216]/255);
    end
    try
        CurrentDir = 'Z:\Data\Jochen';
    catch
    end
else
    hDynamicFilamentsGui=getappdata(0,'hDynamicFilamentsGui');
    children=get(hDynamicFilamentsGui.fig, 'Children');
    delete(children);
    Quicksave(1);
end

c = get(hDynamicFilamentsGui.fig,'Color');
                  
hDynamicFilamentsGui.pPlotPanel = uipanel('Parent',hDynamicFilamentsGui.fig,'Position',[0.4 0.6 0.575 0.395],'Tag','PlotPanel','BackgroundColor','white');

hDynamicFilamentsGui.aPlot = axes('Parent',hDynamicFilamentsGui.pPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','aPlot','TickDir','in');

hDynamicFilamentsGui.pVelPlotPanel = uipanel('Parent',hDynamicFilamentsGui.fig,'Position',[0.4 .005 0.575 0.3],'Tag','VelPlotPanel','BackgroundColor','white');

hDynamicFilamentsGui.pIPlotPanel = uipanel('Parent',hDynamicFilamentsGui.fig,'Position',[0.4 .305 0.575 0.295],'Tag','VelPlotPanel','BackgroundColor','white');

hDynamicFilamentsGui.aVelPlot = axes('Parent',hDynamicFilamentsGui.pVelPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','VelPlot','TickDir','in');

hDynamicFilamentsGui.aIPlot = axes('Parent',hDynamicFilamentsGui.pIPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','aIPlot','TickDir','in');

hDynamicFilamentsGui.lSelection = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fJKDynamicFilamentsGui(''Draw'',getappdata(0,''hDynamicFilamentsGui''));',...
                                   'Position',[0.025 0.6 0.35 0.39],'String','','Style','listbox','Value',1,'Tag','lSelection','min',0,'max',10);
                    
hDynamicFilamentsGui.bLegend = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''Legend'');',...
                                   'Position',[0.025 0.57 0.05 0.025],'String','Legend','Style','pushbutton','Tag','bLegend');      
                               
tooltipstr=sprintf(['Order objects by...']);

hDynamicFilamentsGui.lSortFilaments = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SortFilaments'',getappdata(0,''hDynamicFilamentsGui''));',...
                            'Position',[0.1 0.565 0.05 0.025],'Fontsize',10,'BackgroundColor','white','String',{'By Date','By Type'},'Value',1,'Style','popupmenu','Tag','lSortFilaments','Enable','on','TooltipString', tooltipstr);   
                        
hDynamicFilamentsGui.bSelectAll = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.17 0.57 0.05 .025],'Tag','bSelectAll','Fontsize',10,...
                              'String','Select All','Callback','fJKDynamicFilamentsGui(''Select'');');   
                          
hDynamicFilamentsGui.bIntoWorkSpace = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.25 0.57 0.05 .025],'Tag','bSelectAll','Fontsize',10,...
                              'String','Into Workspace','Callback','fJKDynamicFilamentsGui(''Workspace'');');   
                          
hDynamicFilamentsGui.bDelete = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.325 0.57 0.05 .025],'Tag','bDelete','Fontsize',10,...
                              'String','Delete Selected','Callback','fJKDynamicFilamentsGui(''Delete'');');    
                          
hDynamicFilamentsGui.bCustom = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''CustomPlot'');',...
                                   'Position',[0.9775 0.9 0.02 0.03],'String','custom','Style','pushbutton','Tag','bCustomPlot');   
                          
hDynamicFilamentsGui.bSurf = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SurfPlot'');',...
                                   'Position',[0.9775 0.8 0.02 0.03],'String','surf','Style','pushbutton','Tag','bSurf');   
                          
hDynamicFilamentsGui.bTIF = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.7 0.02 0.03],'String','tif','Style','pushbutton','Tag','bTIF');   
                               
hDynamicFilamentsGui.bPDF = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.6 0.02 0.03],'String','pdf','Style','pushbutton','Tag','bTIF');   
                               
hDynamicFilamentsGui.bTXT = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.5 0.02 0.03],'String','doc','Style','pushbutton','Tag','btxt'); 
                               
hDynamicFilamentsGui.bLOCATION = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.4 0.02 0.03],'String','max','Style','pushbutton','Tag','bLOCATION');   
                               
hDynamicFilamentsGui.bFOLDER = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.3 0.02 0.03],'String','folder','Style','pushbutton','Tag','bFOLDER');   
                               
hDynamicFilamentsGui.bFIESTA = uicontrol('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.2 0.02 0.03],'String','FIESTA','Style','pushbutton','Tag','bFIESTA'); 
     
hDynamicFilamentsGui.pOptions = uipanel('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.025 0.07 0.35 0.5],'Tag','pOptions','BackgroundColor',c);
                         
tooltipstr = 'Useful for development and first thing you should try if the GUI appears to be broken.';        
                         
hDynamicFilamentsGui.bRefreshGui = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''Create'', 1);',...
                                   'Position',[0.8 0.93 0.12 0.05],'String','Refresh GUI','Style','pushbutton','Tag','bRefreshGui','TooltipString', tooltipstr);  
                               
tooltipstr = 'Segments the currently loaded MTs according to the given parameters.';       
                               
hDynamicFilamentsGui.bSegment = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback',@UpdateOptions, 'FontSize', 15,...
                                   'Position',[0.65 0.85 0.12 0.05],'String','Segment','Style','pushbutton','Tag','bSegment','TooltipString', tooltipstr);    
                             
tooltipstr=sprintf(['Minimum distance filament has to shrink in order for it to count as a catastrophe. To determine where shrinking segments are to be found.\n' ...
    'Only if the MT monotonously shrinks that distance it can be considered a shrinking segment (other condition see edit box to the right).']);

hDynamicFilamentsGui.tMinDist = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.825 0.3 0.125],'String','Min Shrinkage Distance:','Style','text','Tag','tIntensity','HorizontalAlignment','left');  
                        
hDynamicFilamentsGui.eMinDist = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized','Callback',@UpdateOptions,...
                                'Position',[.3 0.9 .1 .05],'String','400','Style','edit','Fontsize',10,'BackgroundColor','white',...
                                'UserData', 'nm', 'Tag','eMinDist','Value',0,'Enable','on'); 
                            
tooltipstr=sprintf(['Maximum rebound. To determine where shrinking segments are to be found.\n' ...
    'The bigger this fraction, the more small shrinkage segments you will "discover" due to noise in the data.']);
                                     
hDynamicFilamentsGui.eMaxRebound = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.45 0.9 .1 .05],'Tag','eMaxRebound','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', '1', 'String','0.25','BackgroundColor','white','HorizontalAlignment','center');  
                              
hDynamicFilamentsGui.tMaxTimeDiff = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.775 0.3 0.125],'String','Max time difference:','Style','text','Tag','tMaxTimeDiff','HorizontalAlignment','left');  

tooltipstr=sprintf(['If two points are further apart in time than this value [in seconds] they are not joined into one track but seperated.\n' ...
     'This only works at borders of segments. If a shrinkage segment follows a growth segment, a catastrophe will be assumed in between, but this shrinkage track will not show up in plots with references to start.']);
    
hDynamicFilamentsGui.eMaxTimeDiff = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.3 0.85 .1 .05],'Tag','eMaxTimeDiff','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 's','String','20','BackgroundColor','white','HorizontalAlignment','center');    
                                     
    
hDynamicFilamentsGui.tBorders = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.725 0.225 0.125],'String','Track borders:','Style','text','Tag','tVelocityCutoff','HorizontalAlignment','left'); 

tooltipstr=sprintf(['Max step size. To determine the borders of a shrinking segment.\n' ...
    'If a step is above this threshold, the track is terminated (starts from point with minimum velocity outwards).\n' ...
    'Important: The track is not terminated if the condition of the next edit box is fulfilled (see tooltip) \n' ...
    'Effects can be seen in the plots of each track (just try it). The higher this value, the longer the tracks.']);

hDynamicFilamentsGui.eMinXChange = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[0.3 0.8 .1 .05],'Tag','eMinXChange','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'nm','String','0','BackgroundColor','white','HorizontalAlignment','center');  
                                     
tooltipstr=sprintf(['Min step factor. To determine the borders of a shrinking segment.\n' ...
    'If a step in question times the factor given in this box is completely offset by the next step, the track is not terminated at that step.\n' ...
    'The bigger this number, the shorter the tracks.']);
    
hDynamicFilamentsGui.eMinXFactor = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.45 0.8 .1 .05],'Tag','eMinXFactor','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', '1','String','4','BackgroundColor','white','HorizontalAlignment','center');            
                                     
hDynamicFilamentsGui.tIntensity = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.675 0.225 0.125],'String','Pixels from end:','Style','text','Tag','tIntensity','HorizontalAlignment','left');   
                         
tooltipstr = 'How many pixels from MT end to evaluate for GFP intensity calculation. Only applies to intensity/MAP count plots.';
hDynamicFilamentsGui.eIevalLength = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.3 .75 .1 .05],'String','10','Style','edit','Fontsize',10,...
                                'UserData', 'pixels','BackgroundColor','white','Tag','eIevalLength','Value',0,'Enable','on');            

hDynamicFilamentsGui.tDisregard = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                                'Position',[0.5 0.675 0.225 0.125],'String','Disregard:','Style','text','Tag','tDisregard','HorizontalAlignment','left');   
                         
tooltipstr = 'Within this distance to the seed, points are not considered for growth segments (all points between first and last occurence of points within this range in nm). Also, shrinking events are disregarded if they start below this threshold.';
hDynamicFilamentsGui.eDisregard = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.6 .75 .1 .05],'String','157','Style','edit','Fontsize',10,'BackgroundColor','white','Tag','eDisregard',...
                                'UserData', 'nm','Value',0,'Enable','on');            
                           

hDynamicFilamentsGui.tSubsegments = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.625 0.225 0.125],'String','Subsegmenting:','Style','text','Tag','tIntensity','HorizontalAlignment','left');
                         
tooltipstr = sprintf('Border of the first subsegment. The first point with a velocity higher than x%% of the maximum velocity is part of the middle segment.\n Set to 0 to save computation time.');
hDynamicFilamentsGui.eSubStart = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.3 .7 .1 .05],'String','0','Style','edit',...
                                'UserData', '1','Fontsize',10,'BackgroundColor','white','Tag','eSubStart','Value',0,'Enable','on');            
% tooltipstr = '.';
% hDynamicFilamentsGui.eSubMiddle = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
%                                 'Position',[.4 .7 .1 .05],'String','10','Style','edit','Fontsize',10,'BackgroundColor','white','Tag','eIevalLength','Value',0,'Enable','on');            
tooltipstr = sprintf('Border of the last subsegment. The first point (backwards) with a velocity higher than x%% of the maximum velocity is part of the middle segment.\n Set to 0 to save computation time.');
hDynamicFilamentsGui.eSubEnd = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.5 .7 .1 .05],'String','0','Style','edit','Fontsize',10,...
                                'UserData', '1','BackgroundColor','white','Tag','eSubEnd','Value',0,'Enable','on');            

                            
% tooltipstr=sprintf(['Detects rescues within a shrinking segment. A rescue is given if a MT grows during shrinking (the surrounding steps are below the max step size).\nThese catastrophes are not considered for the catastrophe frequency plots!!!']);
%                            
% hDynamicFilamentsGui.cDoubleCat = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
%                                          'Position',[.6 0.65 .4 .1],'Tag','cDoubleCat','Fontsize',10,'TooltipString', tooltipstr,...
%                                          'String','Catas after rescues','BackgroundColor',c,'HorizontalAlignment','center'); 
                                     
tooltipstr=sprintf('Tagged with 8 in the tag4/tag7 field');
                                     
hDynamicFilamentsGui.cIncludeUnclearPoints = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.75 .75 .25 .05],'Tag','cIncludeUnclearPoints','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Include unclear points','BackgroundColor',c,'HorizontalAlignment','center');       

tooltipstr=sprintf('Include points where the MT tip is not in a configuration according to its type. \n Tags in the tag5/tag8 field (0=according to type, 15=one MT less, 1=one MT more, 14=close to template tip');  
                                     
hDynamicFilamentsGui.cIncludeNonTypePoints = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.75 .7 .25 .05],'Fontsize',10,'TooltipString', tooltipstr, 'Tag', 'cIncludeNonTypePoints',...
                                         'String','Include non-type datapoints','BackgroundColor',c,'HorizontalAlignment','center');       
                                     
hDynamicFilamentsGui.tMethod_TrackValue = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.5 0.29 0.125],'String','Determine track value by:','Style','text','Tag','tVelocity','HorizontalAlignment','left');     

hDynamicFilamentsGui.lMethod_TrackValue = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized',...
                            'Position',[0.3 0.5 0.3 0.125],'BackgroundColor','white','String',{'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'sum or linear fit (only for velocity)'},...
                            'Value',1,'Style','popupmenu','Tag','lMethod_TrackValue','Enable','on');   
                        
hDynamicFilamentsGui.lMethod_TrackValueY = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized',...
                            'Position',[0.65 0.5 0.3 0.125],'BackgroundColor','white','String',{'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'},...
                            'Value',1,'Style','popupmenu','Tag','lMethod_TrackValueY','Enable','on');   
                        
tooltipstr=sprintf(['Applies a walking average to the X-Variable (number indicates over how many points). 1 = no smoothing. Only has effect on "X vs Y" and "Events along X during Y" plots.\n Uses "nanfastsmooth" (google it).']);
    
hDynamicFilamentsGui.tSmooth = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.45 0.225 0.125],'String','Smooth:','Style','text','Tag','tSmooth','HorizontalAlignment','left'); 

hDynamicFilamentsGui.eSmoothX = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[0.3 0.53 .05 .04],'Tag','eSmoothX','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'kernel width','String','1','BackgroundColor','white','HorizontalAlignment','center');  
                                     
tooltipstr=sprintf(['Affects how the current MT is plotted in the panels to the right (distance, intensity and velocity are smoothed).\n'...
    'Applies a walking average to the Y-Variable (number indicates over how many points). 1 = no smoothing. Only has effect on "X vs Y" and "Events along X during Y" plots.\n Uses "nanfastsmooth" (google it).']);
                                     
hDynamicFilamentsGui.eSmoothY = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized','Callback','fJKDynamicFilamentsGui(''Draw'',getappdata(0,''hDynamicFilamentsGui''));',...
                                         'Position',[0.4 0.53 .05 .04],'Tag','eSmoothY','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'kernel width','String','1','BackgroundColor','white','HorizontalAlignment','center');  

hDynamicFilamentsGui.tChoosePlot = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.4 0.225 0.125],'String','Plot:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');     
hDynamicFilamentsGui.bUpdatePlots = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback',@UpdateOptions,...
                                   'Position',[0.15 0.45 0.12 0.05],'String','Update All','Style','pushbutton','Tag','bUpdatePlots');     
                               
tooltipstr=sprintf(['Set the X variable.']);
                               
hDynamicFilamentsGui.lPlot_XVar = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized', 'UserData', {'s', 'nm', 'nm/s', '1', '', '1', '?', '?'},...
                            'Position',[0.3 0.4 0.2 0.125],'BackgroundColor','white','String',{'time', 'location', 'velocity', 'MAP count', 'auto tags', 'frames', 'custom data 1', 'custom data 2'}, 'TooltipString', tooltipstr,'Style','popupmenu','Tag','lPlot_XVar','Enable','on');
                       

tooltipstr=sprintf(['Set the Y variable and plot (Either "X vs Y" or "Events along X during Y" have to be selected below).']);
                        
hDynamicFilamentsGui.lPlot_YVar = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized', 'UserData', {'s', 'nm', 'nm/s', '1', '', '1', '?', '?'},...
                            'Position',[0.55 0.4 0.2 0.125],'BackgroundColor','white','String',{'time', 'location', 'velocity', 'MAP count', 'auto tags', 'frames', 'custom data 1', 'custom data 2'}, 'TooltipString', tooltipstr,'Style','popupmenu','Tag','lPlot_YVar','Enable','on');

% hDynamicFilamentsGui.YUnits = {'s', 'nm', 'nm/s', '1', '1/s'};
          
hDynamicFilamentsGui.lChoosePlot = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SetMenu'',getappdata(0,''hDynamicFilamentsGui''));', 'Value', 3,...
                            'Position',[0.3 0.35 0.3 0.125],'BackgroundColor','white','TooltipString', tooltipstr,'Style','popupmenu','Tag','lChoosePlot','Enable','on', ...
                            'String',{'X vs Y', 'Events along X during Y', 'Events', 'Box(X)', 'X vs Y (Tracks)', 'Dataset (rough)', 'Shape of Filament End', 'Plot X against Y of tracks of same MT', 'MAP vs distance weighted velocity'});
                        
hDynamicFilamentsGui.bDoPlot = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback',@UpdateOptions,...
                                   'Position',[0.65 0.4 0.12 0.05],'String','Plot','Style','pushbutton', 'FontSize', 15); 
                               
hDynamicFilamentsGui.bDeletePlots = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''DeletePlots'');',...
                                   'Position',[0.8 0.45 0.12 0.05],'String','Close All','Style','pushbutton'); 
                               
tooltipstr=sprintf(['When you have a plot open you can conveniently save it pressing "s".']);
                               
hDynamicFilamentsGui.tQuickInfo = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c, 'TooltipString', tooltipstr,...
                             'Position',[0.8 0.4 0.65 0.03],'String','Save fig pressing "s"','Style','text','Tag','tIntensity','HorizontalAlignment','left');   
                         
hDynamicFilamentsGui.tSubsegment = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.275 0.225 0.125],'String','Select segment(s):','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
                         
hDynamicFilamentsGui.lSubsegment = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized',...
                            'Position',[0.3 0.29 0.3 0.125],'BackgroundColor','white','String',{'All','Beginning','Middle','End', 'Beginning and Middle', 'Middle and End', 'Middle to End'}, ...
                            'Style','popupmenu','Enable','on', 'Value', 1, 'Tag', 'lSubsegment');   

         
hDynamicFilamentsGui.tPlotRef = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.225 0.225 0.125],'String','x axis reference:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
                         
hDynamicFilamentsGui.mXReference = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized',...
                            'Position',[0.3 0.24 0.3 0.125],'BackgroundColor','white','String',{'No reference','To start (with events only)','To end (with events only)','To median', 'To track velocity (velocity only)','To start (all tracks)','To end (all tracks)'}, ...
                            'Style','popupmenu','Tag','mXReference','Enable','on', 'Value', 1); 
                        
tooltipstr=sprintf('Only plots data from selected Filaments (does not work for all plots).');
                                
hDynamicFilamentsGui.cOnlySelected = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[0.65 0.35 0.15 0.05],'Tag','cOnlySelected','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Only Selected','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                                     
tooltipstr=sprintf('Plots a legend (does not work for all plots).');
                                
hDynamicFilamentsGui.cLegend = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized', 'Tag', 'cLegend',...
                                         'Position',[0.65 0.3 0.15 0.05],'Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Legend','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 1);  
                                     
tooltipstr=sprintf('Groups points of tracks which come from the same microtubule into one color and one legend entry.');
                                
hDynamicFilamentsGui.cGroupIntoMTs = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized', 'Tag', 'cGroupIntoMTs',...
                                         'Position',[0.65 0.25 0.15 0.05],'Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Group Tracks','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 1);  

tooltipstr=sprintf('Plots data from untagged (growing) tracks.');
                                
hDynamicFilamentsGui.cPlotGrowingTracks = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[0.85 0.35 0.2 0.05],'Tag','cPlotGrowingTracks','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Growing','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                        
hDynamicFilamentsGui.tGroup = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.175 0.225 0.125],'String','Grouping:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
        
tooltipstr=sprintf(['Type&Day&Experiment is only necessary if there are experiments with the same movie number on different days.\n Month/Year only considered for Type&Day.']);

hDynamicFilamentsGui.lGroup = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Style','popupmenu','Tag','lGroup','TooltipString', tooltipstr,...
                             'Position',[0.3 0.19 0.3 0.125],'BackgroundColor','white','String',{'Type','Type&Day','Type&Day&Experiment', 'Pool everything'}, 'Value',2);
                        
tooltipstr=sprintf(['Distinguishes between tracks (marked with *) with and without event in the end.']);
                                                    
hDynamicFilamentsGui.cPlotEventsAsSeperateTypes = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.8 .3 .4 .05],'Tag','cPlotEventsAsSeperateTypes','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Distinguish events','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0); 
                                     
tooltipstr=sprintf(['Excludes first and last points of tracks for plots.']);
                                                                                         
hDynamicFilamentsGui.cExclude = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.65 .175 .4 .05],'Tag','cExclude','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Exclude borders','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                
hDynamicFilamentsGui.tStat = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.1 0.225 0.125],'String','Additional Plots:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
        
tooltipstr=sprintf(['Not functional yet']);

hDynamicFilamentsGui.lAdditionalPlots = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','Style','popupmenu','Tag','lAdditionalPlots','TooltipString', tooltipstr,...
                             'Position',[0.3 0.125 0.3 0.125],'BackgroundColor','white','String',{'None','QQ'}, 'Value',1);
                        
tooltipstr=sprintf(['Shrinking segments ending below this value are considered rescues (except if at end of movie)\n' ...
    'Red line in rescue plot and the track plot (if within y limits)']);
                             
hDynamicFilamentsGui.tRescueCutoff = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.025 0.65 0.125],'String','Rescue Cutoff:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 
                                     
hDynamicFilamentsGui.eRescueCutoff = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized','Callback','fJKDynamicFilamentsGui(''SetTable'');',...
                                         'Position',[.3 .1 .1 .05],'Tag','eRescueCutoff','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','314','BackgroundColor','white','HorizontalAlignment','center');                  
                            
tooltipstr=sprintf(['Takes out tracks with less points than given in the box.']);
                             
hDynamicFilamentsGui.tMinLength = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.45 0.025 0.65 0.125],'String','Min Length:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 
                                     
hDynamicFilamentsGui.eMinLength = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.64 .1 .1 .05],'Tag','eMinLength','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','2','BackgroundColor','white','HorizontalAlignment','center');                  
                            
                                     
tooltipstr=sprintf(['Bin width [nm] for plots which show distance weighted values (instead of frame weighted).']);

hDynamicFilamentsGui.tDistanceWeight = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.75 0.025 0.65 0.125],'String','Dist bins:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 
                                     
hDynamicFilamentsGui.eDistanceWeight = uicontrol('Parent',hDynamicFilamentsGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.89 .1 .1 .05],'Tag','eDistanceWeight','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','20','BackgroundColor','white','HorizontalAlignment','center');                  

                                     
tooltipstr=sprintf(['Shows the track indices (the index of the track within the track structure, see code).']);
                                     
hDynamicFilamentsGui.cshowTrackN = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','checkbox','Units','normalized',...
                                         'Position',[.38 .75 .015 .02],'Tag','cshowTrackN','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','','BackgroundColor',c,'HorizontalAlignment','center','Callback','fJKDynamicFilamentsGui(''Draw'',getappdata(0,''hDynamicFilamentsGui''));');
                                     
hDynamicFilamentsGui.bSave = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.025 .005 .06 .05],'Tag','bSave','Fontsize',12,...
                              'String','Save Links','Callback','fJKDynamicFilamentsGui(''Save'');');      
                          
hDynamicFilamentsGui.bLoad = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.1 .005 .06 .05],'Tag','bLoad','Fontsize',12,...
                              'String','Load File','Callback','fJKDynamicFilamentsGui(''Load'');');         

hDynamicFilamentsGui.bLoadFolder = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.18 .005 .05 .05],'Tag','bLoadFolder','Fontsize',12,...
                              'String','Load Folder','Callback','fJKDynamicFilamentsGui(''LoadFolder'');');     
                          
hDynamicFilamentsGui.bLoadOptions = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.232 .03 .05 .023],'Tag','bLoadOptions','Fontsize',12,...
                              'String','Load Options','Callback',@LoadOptions);     
                          
hDynamicFilamentsGui.bSaveOptions = uicontrol('Parent',hDynamicFilamentsGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.232 .005 .05 .023],'Tag','bSaveOptions','Fontsize',12,...
                              'String','Save Options','Callback',@UpdateOptions);     
                          
hDynamicFilamentsGui.pLoadOptions = uipanel('Parent',hDynamicFilamentsGui.fig,'Units','normalized','Title','What to load',...
                             'Position',[0.3 0.005 0.1 0.12],'Tag','pLoadOptions','BackgroundColor',c);
                          
hDynamicFilamentsGui.cAllowUnknownTypes = uicontrol('Parent',hDynamicFilamentsGui.pLoadOptions,'Units','normalized',...
                             'Position',[0.01 .85 1 0.2],'BackgroundColor',c,'Style','checkbox','Tag','cAllowUnknownTypes','String','Import tracks with ''unknown'' type');  
                          
hDynamicFilamentsGui.cAllowWithoutReference = uicontrol('Parent',hDynamicFilamentsGui.pLoadOptions,'Units','normalized',...
                             'Position',[0.01 .7 1 0.2],'BackgroundColor',c,'Style','checkbox','Tag','cAllowWithoutReference','String','Allow tracks without reference');  

hDynamicFilamentsGui.cUsePosEnd = uicontrol('Parent',hDynamicFilamentsGui.pLoadOptions,'Units','normalized',...
                            'Position',[0.01 .55 1 0.2],'BackgroundColor',c,'String','Use PosEnd instead of PosStart','Style','checkbox','Tag','cUsePosEnd','Enable','on');
                        
                                     
tooltipstr=sprintf(['If you have the intensities in extra files within the same folder as the original file, provide the filename here to load them (without .mat)']);
                                     
hDynamicFilamentsGui.eLoadIntensityFile = uicontrol('Parent',hDynamicFilamentsGui.pLoadOptions,'Style','edit','Units','normalized',...
                                         'Position',[.1 .3 0.8 .2],'Tag','eLoadIntensityFile','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', '.mat', 'String','','BackgroundColor','white','HorizontalAlignment','center');  
                                            
tooltipstr=sprintf(['If you have custom data you can provide the filename here (without .mat)']);
                                     
hDynamicFilamentsGui.eLoadCustomDataFile = uicontrol('Parent',hDynamicFilamentsGui.pLoadOptions,'Style','edit','Units','normalized',...
                                         'Position',[.1 .05 0.8 .2],'Tag','eLoadCustomDataFile','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', '.mat', 'String','','BackgroundColor','white','HorizontalAlignment','center');    

if nargin == 0                                                                
    set(hDynamicFilamentsGui.fig,'Visible','on');
    Objects = fDefStructure([], 'Filament');                                
    setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
    setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);
else
    setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);
end
UpdateOptions()

function keyPress(varargin)
UpdateOptions

function LoadOptions(varargin)
global CurrentDir
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
try
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Options',CurrentDir);
catch
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Options');        
end
CurrentDir=PathName;
Options = load([PathName FileName], 'Options');
Options = Options.Options;
children = get(hDynamicFilamentsGui.pOptions, 'Children');
children = vertcat(children, get(hDynamicFilamentsGui.pLoadOptions, 'Children'));
for i = 1:length(children)
    if isfield(Options, get(children(i), 'tag'))
        switch get(children(i), 'Style')
            case 'checkbox'
                set(children(i), 'value', Options.(get(children(i), 'tag')).val);
            case 'popupmenu'
                set(children(i), 'value', Options.(get(children(i), 'tag')).val);
            case 'edit'
                set(children(i), 'string', num2str(Options.(get(children(i), 'tag')).val));
            otherwise
                continue
        end
    end
end
[Objects, Tracks] = fJKSegment(Options);
setappdata(hDynamicFilamentsGui.fig,'Tracks', Tracks);
setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
SetTable();

function UpdateOptions(varargin)
global CurrentDir
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
children = get(hDynamicFilamentsGui.pOptions, 'Children');
children = vertcat(children, get(hDynamicFilamentsGui.pLoadOptions, 'Children'));
Options = struct;
for i = 1:length(children)
    if isfield(Options, get(children(i), 'tag'))
        error('Field already exists. Check for tag fields with same name of your uicontrols');
    end
    tagname = get(children(i), 'tag');
    switch get(children(i), 'Style')
        case 'checkbox'
            Options.(tagname).val = get(children(i), 'value');
            Options.(tagname).str = '';
            Options.(tagname).print = int2str(Options.(tagname).val);
        case 'popupmenu'
            Options.(tagname).val = get(children(i), 'value');
            strings = get(children(i), 'string');
            Options.(tagname).print = strings{Options.(tagname).val};
            try %currently used for units
                userdata = get(children(i), 'UserData');
                Options.(tagname).str = userdata{Options.(tagname).val};
            catch
            end
        case 'edit'
            Options.(tagname).val = str2double(get(children(i), 'string'));
            if isnan(Options.(tagname).val)
                Options.(tagname).str = get(children(i), 'string');
                Options.(tagname).print = get(children(i), 'string');
            else
                Options.(tagname).str = get(children(i), 'UserData');
                Options.(tagname).print = [num2str(Options.(tagname).val,3) '[' get(children(i), 'UserData') ']'];
            end
        otherwise
            continue
    end
end
setappdata(hDynamicFilamentsGui.fig,'Options',Options);
if gcbo == hDynamicFilamentsGui.bSaveOptions
    try
        [FileName, PathName] = uiputfile({'*.mat','MAT-File (*.mat)';},'Save Options' ,CurrentDir);
    catch
        [FileName, PathName] = uiputfile({'*.mat','MAT-File (*.mat)';},'Save Options');
    end
    if FileName~=0
        file = [PathName FileName];
        if isempty(strfind(file,'.mat'))
            file = [file '.mat'];
        end
        save(file,'Options');
        try
            fShared('SetSaveDir',PathName);
        catch
        end
    end
elseif gcbo == hDynamicFilamentsGui.bDoPlot
    ChoosePlot();
elseif gcbo == hDynamicFilamentsGui.bUpdatePlots
    UpdatePlot(hDynamicFilamentsGui);
else %when the GUI is initialized
    [Objects, Tracks] = fJKSegment(Options);
    setappdata(hDynamicFilamentsGui.fig,'Tracks', Tracks);
    setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
end
SetTable();


function Quicksave(varargin)
global CurrentDir
persistent QuicksaveDir
if nargin>0
    QuicksaveDir = [];
    return
end
if isempty(QuicksaveDir)
    try
        QuicksaveDir = uigetdir(CurrentDir, 'Select the quicksave folder (choice will be remembered until you refresh the GUI).');
    catch 
        QuicksaveDir = uigetdir('','Select the quicksave folder (choice will be remembered until you refresh the GUI).');
    end
end
if strcmp(get(gcf, 'CurrentCharacter'),'s')
    jFrame = get(handle(gcf),'JavaFrame');
    jFrame.setMaximized(true);
%     export_fig([QuicksaveDir filesep strrep(get(gcf, 'Name'), ' | ', '_')], '-png', '-nocrop');
    filename = strrep(get(gcf, 'Name'), ' | ', '_');
    optionsstart = strfind(filename, '- ');
    filename = inputdlg('Filename?', 'Filename?', 1, {filename(1:optionsstart)});
    saveas(gcf,[QuicksaveDir filesep filename{1} '.png'], 'png');
%     savefig(gcf,[QuicksaveDir filesep strrep(get(gcf, 'Name'), ' | ', '_') '.fig']);
end


function AddCustomData
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
[unique_paths, ~, MT_index] = unique(LoadedFromPath, 'stable');
filename = inputdlg('Filename (without .mat)? You will find the data under Object.Custom.<filename>', 'Filename?', 1, 'pixelkymo');
for m=1:length(unique_paths)
    load_data = load([unique_path(m) filename '.mat']);
    for n = find(MT_index == m)
        Objects(n).Custom.(filename).ScanOptions = load_data.ScanOptions;
        for p=1:size(load_data.Data,1)
            if strcmp(Objects(n).Name, load_data.Data{p, 2})
                Objects(n).Custom.(filename).Data = load_data.Data{p, 1};
            end
        end
    end
end


function Save
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
LoadedFromFile = {Objects.LoadedFromFile};
LoadedFromPath = {Objects.LoadedFromPath};
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

function Select
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
set(hDynamicFilamentsGui.lSelection,'Value', 1:length(Objects));
SetTable();

function Workspace
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
selected = get(hDynamicFilamentsGui.lSelection,'Value');
selected = unique(selected);
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Objects = Objects(selected);
assignin('base', 'Objects', Objects)
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
selected_tracks = [];
for m = 1:length(Objects)
    selected_tracks = vertcat(selected_tracks, Objects(m).SegTagAuto(:,5));
end
selected_tracks = unique(selected_tracks);
Tracks = Tracks(selected_tracks(logical(selected_tracks)));
assignin('base', 'Tracks', Tracks)
'workspace updated'

function Delete
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
selected=get(hDynamicFilamentsGui.lSelection,'Value');
keep=setxor(selected, 1:length(Objects));
keep = keep(keep<=length(Objects));
Objects = Objects(keep);
setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);
try
SetTable();
catch
end

function Load(varargin)
global CurrentDir
if nargin > 0
    FileName = varargin{1};
    PathName = varargin{2};
else
    try
        [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Objects',CurrentDir);
    catch
        [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Objects');        
    end
    CurrentDir=PathName;
end
if FileName~=0
    AllObjects = load([PathName FileName], 'Filament');
    if ~isfield(AllObjects, 'Filament')
        fJKLoadLink(FileName, PathName, @Load)
        LoadIntensityPerMAP('intensities.csv', PathName)
    else
        AllObjects = AllObjects.Filament;
        NewObjects = AllObjects([AllObjects.Channel]==1);
        answer = [];
        if ~all([NewObjects.Drift])
            answer = questdlg('Some Filaments had not been drift-corrected. Continue anyway?', 'Warning', 'Yes','No','Yes' );
            if strcmp(answer, 'No')
                return
            end
        end
        aligned = 1;
        driftcorrected = 1;
        RefObjects = AllObjects([AllObjects.Channel]>1);
        if ~isempty(answer)
            for RefObject = RefObjects;
                if RefObject.TformMat(3,3)==1;
                    aligned = 0;
                end
                if RefObject.Drift==0;
                    driftcorrected = 0;
                end
            end
            if ~aligned
                answer = questdlg('Some Reference-Filaments had not been color-aligned. Continue anyway?', 'Warning', 'Yes','No','Yes' );
                if strcmp(answer, 'Yes')
                    if ~driftcorrected
                        answer = questdlg('Some Reference-Filaments had not been drift-corrected. Continue anyway?', 'Warning', 'Yes','No','Yes' );
                        if strcmp(answer, 'No')
                            return
                        end
                    end
                else
                    return
                end
            end
        end
        PrepareFils(NewObjects, RefObjects, PathName, FileName);
    end
end

function custom_data = LoadCustomData(custom_data, custom_data_name)
if ~isempty(strfind(custom_data_name, 'ymo'))
    for m = 1:length(custom_data)
        custom_data{m} = max(custom_data{m}, [], 1);
    end
end

function PrepareFils(NewObjects, RefObjects, PathName, FileName)
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
ref = get(hDynamicFilamentsGui.cUsePosEnd, 'Value')*2+1;
fieldnames = {'Selected','Channel','TformMat','Color','PathData', 'Visible', 'PlotHandles', 'Data', 'TrackingResults'};
NewObjects = rmfield(NewObjects,fieldnames);
str=cell(length(NewObjects),1);
deleteobjects = false(length(NewObjects), 1);
external_intensity_name = get(hDynamicFilamentsGui.eLoadIntensityFile, 'String');
has_external_intensity = 0;
if ~strcmp(external_intensity_name, '')
    try
        ExtIntensity = load([PathName external_intensity_name '.mat']);
        if isfield(ExtIntensity, 'intensities')
            has_external_intensity = 1;
        end
    catch
    end
end
custom_data_name = get(hDynamicFilamentsGui.eLoadCustomDataFile, 'String');
if ~strcmp(custom_data_name, '')
    try
        CustomData = load([PathName custom_data_name '.mat']);
        has_custom_data = 1;
        try 
            FitData = load([PathName custom_data_name '_fit.mat']);
            has_fit_data = 1;
        catch
            has_fit_data = 0;
        end
    catch
        has_custom_data = 0;
    end
end
for i=1:length(NewObjects)
    if has_external_intensity
        NewObjects(i).Custom.Intensity = ExtIntensity.intensities{i};
        NewObjects(i).Custom.type_intensity = external_intensity_name;
    else
        if isfield(NewObjects(i).Custom, 'Intensity')
            NewObjects(i).Custom.type_intensity = 'From File';
        else
            NewObjects(i).Custom.type_intensity = 'None';
        end
    end
    if has_custom_data
        NewObjects(i).Custom.CustomData = LoadCustomData(CustomData.Data{i,1}, custom_data_name);
        NewObjects(i).Custom.type_custom = custom_data_name;
        NewObjects(i).Custom.options_custom = CustomData.ScanOptions;
    else
        NewObjects(i).Custom.type_custom = 'None';
    end
    str{i}=NewObjects(i).Name;
    typecomment=strfind(NewObjects(i).Comments,'type:');
    if ~isempty(typecomment)
        restcomment=NewObjects(i).Comments(typecomment+5:end);
        space=strfind(restcomment(1:end),' ');
        if isempty(space)
            space=length(restcomment(1:end))+1;
        end
        NewObjects(i).Type=restcomment(1:space(1)-1);
        if strcmp(NewObjects(i).Type, 'unknown')
            deleteobjects(i) = 1;
        end
        if strcmp(NewObjects(i).Type(end), 'A')
            NewObjects(i).Type = [NewObjects(i).Type(1:end-1) ' +Ase1'];
        else
            NewObjects(i).Type = [NewObjects(i).Type ' -Ase1'];
        end
    else
        NewObjects(i).Type='n/a';
    end
    NewObjects(i).LoadedFromPath = PathName;
    NewObjects(i).LoadedFromFile = FileName;
end
if ~get(hDynamicFilamentsGui.cAllowUnknownTypes, 'Value') % deletes MTs with unknown type
    NewObjects(deleteobjects) = [];
end
for i=1:length(NewObjects)
    tags = fJKfloat2tags(NewObjects(i).Results(:,end));
    if ref==1
        tiptags = tags(:,7);
        tags = tags(:,6);
    else
        tiptags = tags(:,10);
        tags = tags(:,9);
    end
    catastrophes = tags==10;
    rescues = tags==15;
    if ~get(hDynamicFilamentsGui.cAllowWithoutReference, 'Value')
        refcomment=strfind(NewObjects(i).Comments,'ref:');
        if ~isempty(refcomment)
            RefPos=fJKGetRefData(NewObjects(i), ref, tags==11, RefObjects);
        else
            RefPos=nan;
        end
    else
        RefPos=fJKGetRefData(NewObjects(i), ref, tags==11, RefObjects);
    end
    if isnan(RefPos)
        DynResults = [nan nan nan 1];
    else
        DynResults = [NewObjects(i).Results(:,1:2) RefPos (1:size(RefPos,1))'];
        for m=length(tags):-1:1
            if tags(m)==9||isnan(RefPos(m))
                DynResults(m,:) = [];
                tags(m) = [];
                tiptags(m) = [];
            end
        end
    end
    NewObjects(i).CatRes = [sum(catastrophes) sum(rescues)];
    NewObjects(i).Tags = [tags tiptags];
    NewObjects(i).DynResults = DynResults;
    NewObjects(i).SegTagAuto=[NaN NaN NaN NaN NaN];
    NewObjects(i).Velocity=nan(2,7);
    NewObjects(i).Duration = 0;
    NewObjects(i).Disregard = 0;
end
OldObjects = getappdata(hDynamicFilamentsGui.fig,'Objects');
if ~isempty(OldObjects)
    NewObjects = [OldObjects NewObjects];
end
setappdata(hDynamicFilamentsGui.fig,'Objects',NewObjects);
set(hDynamicFilamentsGui.cUsePosEnd, 'Enable', 'off');
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);
SetTable()

function LoadIntensityPerMAP(FileName, PathName)
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
table = readtable([PathName FileName], 'Format', '%s%s%d', 'Delimiter',';');
for i = 1:length(table.Value)
    if strcmp(table.Moviefolder(i),'all')
        changeobjects = cellfun(@(x) ~isempty(strfind(x, table.Folder(i))), LoadedFromPath);
        for id = find(changeobjects==1)
            Objects(id).Custom.IntensityPerMAP = double(table.Value(i));
        end
    end
end
for i = 1:length(table.Value)
    if ~strcmp(table.Moviefolder(i),'all')
        changeobjects = cellfun(@(x) ~isempty(strfind(x, [table.Folder{i} filesep table.Moviefolder{i}])), LoadedFromPath);
        for id = find(changeobjects==1)
            Objects(id).Custom.IntensityPerMAP = double(table.Value(i));
        end
    end
end
setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);

function LoadFolder(varargin)
global CurrentDir
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
% answer = questdlg('Use link file or open all .mat files within folder which say "dynamics"?', 'Method', 'Link','Folder','Link' );
try
    folder = uigetdir(CurrentDir, 'Select the folder');
catch 
    folder = uigetdir('','Select the folder');
end
CurrentDir = folder;
if folder~=0
    fileList = getAllFiles(folder);
    fileList = fileList(~cellfun(@isempty, strfind(fileList, '.mat'))); %only mat files
    fileList = fileList(~cellfun(@isempty, strfind(fileList, 'dynamics'))|~cellfun(@isempty, strfind(fileList, 'Dynamics'))); %only dynamics
    numfiles = length(fileList);
    progressdlg('String','Loading Files','Min',0,'Max',numfiles,'Parent',hDynamicFilamentsGui.fig);
    for i = 1:numfiles
        [PathName, FileName, ext] = fileparts(char(fileList(i)));
        Load([filesep FileName ext],PathName);
        progressdlg(i);
    end
    UpdateOptions();
end
%     try
%         [FileLink, folder] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link',CurrentDir);
%     catch
%         [FileLink, folder] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link');        
%     end


function Legend
str=sprintf(['For the table:\nColumn 0: MT index\nColumn 1: MT name\n' ...
    'Column 1+: MT has additional comments (+), you can see those in the window name if you select the MT\n' ...
    'Column 2: Number of catastrophes, (tagged|detected by algorithm) \n' ...
    'Column 3: Number of rescues, (tagged|detected by algorithm) \n' ...
    'Column 4: Growth velocity\n' ...
    'Column 5: (Tagged) Shrinkage velocity\n' ...
    'Column 6: Type\n' ...
    'Column 7: Movie\n\n' ...
    'For the plots (except for the event plot and the track velocity plot):\n'...
    'For all scatter plots, data points stemming from the selected MTs have diamond markers.'...
    'The color of the data points is the same if they belong to the same track.\n'...
    'In the x vs event plots, values in parentheses are from the selected MTs.\n'...
    'You can quicksave a plot by pressing "s", it will be saved into the current Matlab folder (name depends on parameters).'...
    ]);
msgbox(str,'Legend');


function SetMenu(hDynamicFilamentsGui)
switch get(hDynamicFilamentsGui.lChoosePlot, 'Value')
    case {1,2}
        set(hDynamicFilamentsGui.mXReference, 'Visible', 'on');
        set(hDynamicFilamentsGui.lSubsegment, 'Visible', 'on');
    case 7
        set(hDynamicFilamentsGui.mXReference, 'Visible', 'off');
        set(hDynamicFilamentsGui.lSubsegment, 'Visible', 'on');
    otherwise
        set(hDynamicFilamentsGui.mXReference, 'Visible', 'off');
        set(hDynamicFilamentsGui.lSubsegment, 'Visible', 'off');
end

function SetTable()
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
cutoff=str2double(get(hDynamicFilamentsGui.eRescueCutoff, 'String'));
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
for n=1:length(Tracks)
    if abs(Tracks(n).Event-4.9)<0.1 && Tracks(n).DistanceEventEnd<cutoff
        Tracks(n).TypeTag = [Tracks(n).Type ' tag4'];
    end
end
str=cell(length(Objects),1);
for n = 1:length(Objects) 
    velocity=Objects(n).Velocity;
    if isempty(strfind(Objects(n).Comments, '+'))
        hascomments=' ';
    else
        hascomments='+';
    end
    segtagauto=Objects(n).SegTagAuto;
    nResAuto=sum(abs(segtagauto(:,3)-4.85)<0.1&segtagauto(:,4)>cutoff);%to get 4.8 (stops of shrinkages not captured) and 4.9
    nCatAuto=sum(abs(segtagauto(:,3)-1.85)<0.1|abs(segtagauto(:,3)-4.8)<0.1); %to get 1.8 (catastrophes not captured) and 1.9
    str{n}=[num2str(n) ' ' Objects(n).Name hascomments ' ' num2str(Objects(n).CatRes(1)) '|' num2str(nCatAuto) '    ' num2str(Objects(n).CatRes(2)) '|' num2str(nResAuto) ...
        '    ' num2str(velocity(1), '%2.2f') '    ' num2str(velocity(2), '%2.1f') '    ' Objects(n).Type '    ' Objects(n).File(1:end-4) '    ' Objects(n).Custom.type_intensity];
end
setappdata(hDynamicFilamentsGui.fig,'Tracks', Tracks);
Draw(hDynamicFilamentsGui);
set(hDynamicFilamentsGui.lSelection, 'String', str);
set(hDynamicFilamentsGui.lSelection, 'Value', max(1,min(get(hDynamicFilamentsGui.lSelection, 'Value'),length(str))));

function SurfPlot()
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
Options = getappdata(hDynamicFilamentsGui.fig,'Options');
Selected=get(hDynamicFilamentsGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    figure('Name', ['Surf: ' Object.Name ' ' Object.File])
    includepoints = ones(size(Object.Tags,1), 1);
    if ~Options.cIncludeUnclearPoints.val
        includepoints = includepoints & Object.Tags(:,1)~=8;
        includepoints = includepoints & Object.Tags(:,1)~=7;
    end
    if ~Options.cIncludeNonTypePoints.val
        includepoints = includepoints & Object.Tags(:,2)==0;
    end
    try
        custom_data = Object.Custom.CustomData(includepoints)';
    catch
        msgbox('you need to have kymograph data loaded as custom data (see in the UI group "What to load"');
    end
    maxLength=max(cellfun(@(x)numel(x),custom_data));
    padded_matrix=cell2mat(cellfun(@(x)cat(2,x, nan(1,maxLength-length(x))),custom_data,'UniformOutput',false));

    surf(padded_matrix)
    hold on;
    zlabel(['Intensity (' get(hDynamicFilamentsGui.eLoadCustomDataFile, 'String') ')'], 'Interpreter', 'none');
    ylabel('frame');
    xlabel('Arc length away from plus end [pixels]');
    l = Object.Custom.options_custom.help_get_tip_kymo.ExtensionLength;
    x_length = size(padded_matrix,1);
    z_min = min(max(padded_matrix(:,1:20,:)));
    z_max = max(max(padded_matrix(:,1:20,:)));
    v = patch([l l l l], [0 0 x_length x_length], [z_min z_max z_max z_min],[0.9, 0.9, 0.9]);
    set(v,'facealpha',0.3);
    set(v,'edgealpha',0.1);
%     value = zeros(1, 428);
%     value2 = zeros(1, 428);
%     for m = 1:428
%         value(m) = padded_matrix(m, 6+ceil(Object.x0(m)));
%         value2(m) = padded_matrix(m, 6+ceil(Object.w0(m)));
%     end
%     plot3(Object.x0+6, 1:length(value), value+100, 'r-');
%     plot3(Object.x0+Object.w0+6, 1:length(value), value2+100, 'g-');
%     track_id=Object.SegTagAuto(:,5);
%     track_id=track_id(track_id>0);
%     tracks=Tracks(track_id);
%     vector = [];
%     for i=1:length(tracks)
%         vector=vertcat(vector, tracks(i).Data(:,6:7));
%     end
%     value=zeros(length(vector), 1);
%     for m = 1:length(vector)
%         value(m) = padded_matrix(m, max(1,ceil(vector(m,2))));
%     end
%     plot3(vector(:,2), vector(:,1), value, 'r-');
end

function CustomPlot()
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Selected=get(hDynamicFilamentsGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    figure('Name', ['Custom Data: ' Object.Name ' ' Object.File])
    hold on;
    track_id=Object.SegTagAuto(:,5);
    track_id=track_id(track_id>0);
    tracks=Tracks(track_id);
    custom1 = subplot(2,1,1);
    custom2 = subplot(2,1,2);
    for i=1:length(tracks)
        segtrack=tracks(i).Data;
        plot(custom1, segtrack(:,1),segtrack(:,7), 'r-');
        try
            plot(custom2, segtrack(:,1),segtrack(:,8), 'b-');
        catch
        end
    end
    xlabel('time [s]');
    legend('data2 (signal)');
    legend(custom1, 'data1 (SNR)', 'data2 (signal)');
end

function Draw(hDynamicFilamentsGui)
showTrackN=get(hDynamicFilamentsGui.cshowTrackN,'Value');
cla(hDynamicFilamentsGui.aPlot, 'reset');
cla(hDynamicFilamentsGui.aVelPlot, 'reset');
cla(hDynamicFilamentsGui.aIPlot, 'reset');
tagnum=4;
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Selected=get(hDynamicFilamentsGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
eSmoothY=str2double(get(hDynamicFilamentsGui.eSmoothY, 'String'));
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    track_id=Object.SegTagAuto(:,5);
    track_id=track_id(track_id>0);
    tracks=Tracks(track_id);
    set(hDynamicFilamentsGui.fig, 'Name',['Dynamics: ' Object.Name '  (' Object.Comments ')']);
    modevents=mod(Object.SegTagAuto(Object.SegTagAuto(:,5)>0,3),1);
    cutoff=str2double(get(hDynamicFilamentsGui.eRescueCutoff, 'String'));
    if isempty(track_id)
    else
    if tracks(1).HasIntensity
        set(hDynamicFilamentsGui.pPlotPanel,'Position',[0.4 0.6 0.575 0.395]);
        set(hDynamicFilamentsGui.pIPlotPanel,'Visible','on');
    else
        set(hDynamicFilamentsGui.pPlotPanel,'Position',[0.4 0.305 0.575 0.69]);
        set(hDynamicFilamentsGui.pIPlotPanel,'Visible','off');
    end
    hold(hDynamicFilamentsGui.aVelPlot,'on');
    hold(hDynamicFilamentsGui.aIPlot,'on');
    hold(hDynamicFilamentsGui.aPlot,'on');
    axes(hDynamicFilamentsGui.aPlot);
    for i=1:length(tracks)
        segtrack=tracks(i).Data;
        tseg=segtrack(:,1);
        pauses=find(segtrack(:,5)==8);
        if eSmoothY == 1
            dseg=segtrack(:,2);
            vseg=segtrack(:,3);
            iseg=segtrack(:,4);
        else
            dseg=nanfastsmooth(segtrack(:,2), eSmoothY);
            vseg=nanfastsmooth(segtrack(:,3), eSmoothY);
            iseg=nanfastsmooth(segtrack(:,4), eSmoothY);
        end
        d0=round(nanmean(segtrack(:,2)));
        t0=segtrack(round(size(segtrack,1)/2),1);
        if showTrackN
            text(double(t0),double(max(segtrack(:,2))),num2str(track_id(i)));
        end
        plot(hDynamicFilamentsGui.aPlot,tseg(pauses),dseg(pauses),'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor','c');
        if floor(tracks(i).Event)==tagnum
            c='r';
            if size(dseg,1) < str2double(get(hDynamicFilamentsGui.eMinLength, 'String'))
                c=[0.7 0.7 0.7];
            end
            if modevents(i)>0.85&&dseg(end)>cutoff
                plot(hDynamicFilamentsGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            elseif modevents(i)>0.7&&dseg(end)>cutoff
                plot(hDynamicFilamentsGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            end
        else
            c='k';
            if modevents(i)>0.85
                plot(hDynamicFilamentsGui.aPlot,tseg(end),dseg(end),'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            elseif modevents(i)>0.7
                plot(hDynamicFilamentsGui.aPlot,t0,max(dseg)+d0/10,'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor',c);
            end
        end
        plot(hDynamicFilamentsGui.aPlot,tseg,tracks(i).Velocity(end).*(tseg-t0)+d0,'b-.');
        plot(hDynamicFilamentsGui.aVelPlot,tseg,repmat(tracks(i).Velocity(end), 1, length(tseg)),'b-.');
        plot(hDynamicFilamentsGui.aPlot,tseg,dseg,'Color', c);
        if tracks(i).end_first_subsegment
            plot(hDynamicFilamentsGui.aPlot,tseg(tracks(i).end_first_subsegment),dseg(tracks(i).end_first_subsegment),'LineStyle', 'none', 'Marker', 'd', 'MarkerEdgeColor',c);
        end
        if tracks(i).start_last_subsegment
            plot(hDynamicFilamentsGui.aPlot,tseg(tracks(i).start_last_subsegment),dseg(tracks(i).start_last_subsegment),'LineStyle', 'none', 'Marker', 's', 'MarkerEdgeColor',c);
        end
        plot(hDynamicFilamentsGui.aVelPlot,tseg,vseg,'Color', c);
        plot(hDynamicFilamentsGui.aIPlot,tseg,iseg,'Color', c);
    end
    xy=get(hDynamicFilamentsGui.aPlot,{'xlim','ylim'});
    if xy{2}(1)<cutoff&&xy{2}(2)>cutoff
        plot(hDynamicFilamentsGui.aPlot,[xy{1}(1) xy{1}(2)] , [cutoff cutoff], 'r-')
    end
    set(hDynamicFilamentsGui.aPlot,{'xlim','ylim'},xy);
    legend(hDynamicFilamentsGui.aPlot,'off');
    xlabel(hDynamicFilamentsGui.aPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aPlot,'distance [nm]'); 
    xlabel(hDynamicFilamentsGui.aVelPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aVelPlot,'velocity [nm/s]'); 
    xlabel(hDynamicFilamentsGui.aIPlot,'time [s]');
    ylabel(hDynamicFilamentsGui.aIPlot,'GFP intensity [AU]'); 
    zoom(hDynamicFilamentsGui.aPlot, 'on');
    zoom(hDynamicFilamentsGui.aVelPlot, 'on');
    zoom(hDynamicFilamentsGui.aIPlot, 'on');
    linkaxes([hDynamicFilamentsGui.aPlot,hDynamicFilamentsGui.aIPlot, hDynamicFilamentsGui.aVelPlot],'x')
    end
    for i=2:length(Selected)
        Object = Objects(Selected(i));
        tmp=Object.SegTagAuto(:,5);
        track_id=[track_id; tmp(tmp>0)];
    end
    for i=1:length(Tracks)
        if ismember(i,track_id)
            Tracks(i).Selected=1;
        else
            Tracks(i).Selected=0;
        end
    end
    if isempty(tracks)
        text(0.2,0.5,'No data available for current object. You might need to press "Segment".','Parent',hDynamicFilamentsGui.aPlot,'FontWeight','bold','FontSize',16);
    end
end
setappdata(hDynamicFilamentsGui.fig,'Tracks', Tracks);
setappdata(0,'hDynamicFilamentsGui',hDynamicFilamentsGui);

function OpenInfo
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
Selected=get(hDynamicFilamentsGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
Object = Objects(Selected(1));
if gcbo == hDynamicFilamentsGui.bTIF
    OpenFile = [Object.LoadedFromPath Object.Name '.tif'];
elseif gcbo == hDynamicFilamentsGui.bPDF
    OpenFile = [Object.LoadedFromPath Object.Name '.pdf'];
elseif gcbo == hDynamicFilamentsGui.bTXT
    seps = strfind(Object.LoadedFromPath, filesep);
    dirData = dir(Object.LoadedFromPath(1:seps(end-1)));      %  Get the data for the current directory
    dirIndex = [dirData.isdir];  %  Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'  Get a list of the files
    OpenFile = [];
    for file = fileList'
        if strfind(file{1}, 'Protocol')
            OpenFile = [Object.LoadedFromPath(1:seps(end-1)) file{1}];
        end
    end
    if isempty(OpenFile)
        errordlg(['No file containing ''Protocol'' in its filename has been found in ' Object.LoadedFromPath(1:seps(end-1))])
        return
    end
elseif gcbo == hDynamicFilamentsGui.bLOCATION
    OpenFile = [Object.LoadedFromPath 'maximum' '.tif'];
elseif gcbo == hDynamicFilamentsGui.bFOLDER
    OpenFile = Object.LoadedFromPath;
elseif gcbo == hDynamicFilamentsGui.bFIESTA
    fMenuData('LoadTracks', Object.LoadedFromFile, Object.LoadedFromPath);
    return
end
try
    if isunix
        system(['open ' OpenFile]);
    else
        winopen(OpenFile);
    end
catch
    errordlg(['File ' OpenFile ' is not available. Maybe the file you are looking for has a different filename/folder or it hasnt been generated yet?']);
end

function UpdatePlot(hDynamicFilamentsGui)
h=findobj('Tag','Plot');
userdatacell=get(h, 'UserData');
delete(h);
for userdata=userdatacell'
    if ~isempty(userdata)
        if ~isnumeric(userdata)
            userdata=cell2mat(userdata);
        end
        userdatafixed=max(userdata,1);
        if userdatafixed > 10
            if userdatafixed > 99
                set(hDynamicFilamentsGui.lChoosePlot, 'Value', 2);
                userdatafixed = userdatafixed-100;
            else
                set(hDynamicFilamentsGui.lChoosePlot, 'Value', 1);
            end
            set(hDynamicFilamentsGui.lPlot_XVar, 'Value', floor(userdatafixed/10));
            set(hDynamicFilamentsGui.lPlot_YVar, 'Value', mod(userdatafixed,10));
        else
            set(hDynamicFilamentsGui.lChoosePlot, 'Value', userdatafixed);
        end
        ChoosePlot();
    end
end
set(hDynamicFilamentsGui.lChoosePlot, 'Value', 3);

function DeletePlots
h=findobj('Tag','Plot');
delete(h);

function ChoosePlot()
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
userdata = {'s', 'nm', 'nm/s', '1', '', '1', '1', 'AU'};
string = {'time', 'location', 'velocity', 'MAP count', 'auto tags', 'frames', 'SNR', 'signal'};
set(hDynamicFilamentsGui.lPlot_XVar, 'UserData', userdata ,'String', string);
set(hDynamicFilamentsGui.lPlot_YVar, 'UserData', userdata ,'String', string);
Options = getappdata(hDynamicFilamentsGui.fig,'Options');
f=figure;
str = [' - '];
optionfields = fields(Options);
for field = optionfields'
    fchar = char(field);
    if strcmp(fchar, 'lChoosePlot') || strcmp(fchar, 'lPlot_XVar') || strcmp(fchar, 'lAdditionalPlots') || ...
            strcmp(fchar, 'lPlot_YVar') || strcmp(fchar, 'cPlotGrowingTracks') || strcmp(fchar, 'cLegend') || strcmp(fchar, 'cOnlySelected') || strcmp(fchar, 'lMethod_TrackValue') || strcmp(fchar, 'lMethod_TrackValueY')
        continue
    end
    str = [str fchar '=' Options.(fchar).print ' | '];
end
uicontrol(f, 'Style', 'text', 'String',str(4:end), 'Units','norm', 'Position', [0.1 0.98 0.9 0.02]);
set(f,'WindowKeyPressFcn','fJKDynamicFilamentsGui(''Quicksave'');');
ChosenPlot = get(hDynamicFilamentsGui.lChoosePlot, 'Value');
if ChosenPlot < 3
    XStr = Options.lPlot_XVar.print;
    YStr = Options.lPlot_YVar.print;
    XVar = Options.lPlot_XVar.val;
    YVar = Options.lPlot_YVar.val;
    if ChosenPlot == 1
        set(f, 'Name',[XStr ' vs ' YStr str], 'Tag', 'Plot', ...
            'UserData', XVar*10+YVar);
        PrepareXYData(0 , Options);
    else
        set(f, 'Name',['Events along ' XStr ' per ' YStr str], 'Tag', 'Plot', ...
            'UserData', 100+XVar*10+YVar);
        PrepareXYData(1 , Options);
    end
else
    plotstr = get(hDynamicFilamentsGui.lChoosePlot, 'String');
    set(f, 'Name',[plotstr{ChosenPlot} str], 'Tag', 'Plot', 'UserData', ChosenPlot);
    switch ChosenPlot
        case 3
            EventPlot(Options.lGroup.val, Options.eRescueCutoff.val);
        case 4
            BoxPlot(Options);
        case 5
            TrackXYPlot(Options);
        case 6
            DataPlot(hDynamicFilamentsGui);
        case 7
            answer = questdlg('Format intensity into error function shape?', 'Option', 'Yes','No','Yes' );
            if strcmp(answer, 'Yes')
                has_err_fun_format = 1;
            else
                has_err_fun_format = 0;
            end
            FilamentEndPlot(hDynamicFilamentsGui, has_err_fun_format);
        case 8
%             button = fQuestDlg('Against which tracks of the same MT?','Which tracks?',...
%                 {'Previous Growing Track', 'Previous Shrinking Track', 'All Other Growing', 'All Other Shrinking'},'Previous Growing Track', 'noplacefig');
%             if strcmp(button,'Previous Growing Track')
%                 ChosePlusTracks = 1;
%                 ChosePreviousTrack = 1;
%             elseif strcmp(button,'Previous Shrinking Track')
%                 ChosePlusTracks = 0;
%                 ChosePreviousTrack = 1;
%             elseif strcmp(button,'All Other Growing')
%                 ChosePlusTracks = 1;
%                 ChosePreviousTrack = 0;
%             elseif strcmp(button,'All Other Shrinking')
%                 ChosePlusTracks = 0;
%                 ChosePreviousTrack = 0;
%             end
            button = fQuestDlg('Against which tracks of the same MT?','Which tracks?',...
                {'All Other Growing', 'All Other Shrinking'},'All Other Growing', 'noplacefig');
            if strcmp(button,'All Other Growing')
                ChosePlusTracks = 1;
                ChosePreviousTrack = 0;
            elseif strcmp(button,'All Other Shrinking')
                ChosePlusTracks = 0;
                ChosePreviousTrack = 0;
            end
            AgainstOtherMTTracksPlot(Options, ChosePlusTracks, ChosePreviousTrack);
        case 9
            IntensityVsDistWeightedVel(Options);
    end
end

function PrepareXYData(isfrequencyplot, Options)
[type, Tracks, events]=SetType(Options.cPlotGrowingTracks.val);
xcolumn = Options.lPlot_XVar.val;
ycolumn = Options.lPlot_YVar.val;
if Options.mXReference.val == 5
    if ycolumn == 3
        for i=1:length(Tracks)
            Tracks(i).Data(:,3) = Tracks(i).Data(:,3)-Tracks(i).Velocity(Options.lMethod_TrackValue.val);
        end
    else
        return
    end
end
if Options.eSmoothX.val > 1
    for i=1:length(Tracks)
        Tracks(i).X = nanfastsmooth(Tracks(i).Data(:,xcolumn), Options.eSmoothX.val);
    end
else
    for i=1:length(Tracks)
        Tracks(i).X = Tracks(i).Data(:,xcolumn);
    end
end
if Options.eSmoothY.val > 1
    for i=1:length(Tracks)
        Tracks(i).Y = nanfastsmooth(Tracks(i).Data(:,ycolumn), Options.eSmoothY.val);
    end
else
    for i=1:length(Tracks)
        Tracks(i).Y = Tracks(i).Data(:,ycolumn);
    end
end
[Tracks, DelObjects] = SelectSubsegments(Tracks, Options);
Tracks(DelObjects) = [];
events(DelObjects) = [];
type(DelObjects) = [];
Tracks = rmfield(Tracks, 'Data');
fJKplotframework(Tracks, type, isfrequencyplot, events, Options);

function [Tracks, DelObjects] = SelectSubsegments(Tracks, Options)
DelObjects = false(length(Tracks),1);
switch Options.lSubsegment.val
    case 2
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment
                Tracks(i).X = Tracks(i).X(1:Tracks(i).end_first_subsegment);
                Tracks(i).Y = Tracks(i).Y(1:Tracks(i).end_first_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 3
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).X = Tracks(i).X(Tracks(i).end_first_subsegment:Tracks(i).start_last_subsegment);
                Tracks(i).Y = Tracks(i).Y(Tracks(i).end_first_subsegment:Tracks(i).start_last_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 4
        for i=1:length(Tracks)
            if Tracks(i).start_last_subsegment
                Tracks(i).X = Tracks(i).X(Tracks(i).start_last_subsegment:end);
                Tracks(i).Y = Tracks(i).Y(Tracks(i).start_last_subsegment:end);
            else
                DelObjects(i) = 1;
            end
        end
    case 5
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).X = Tracks(i).X(1:Tracks(i).start_last_subsegment);
                Tracks(i).Y = Tracks(i).Y(1:Tracks(i).start_last_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 6
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).X = Tracks(i).X(Tracks(i).end_first_subsegment:end);
                Tracks(i).Y = Tracks(i).Y(Tracks(i).end_first_subsegment:end);
            else
                DelObjects(i) = 1;
            end
        end
    case 7
        for i=1:length(Tracks)
            if Tracks(i).minindex > 1 && Tracks(i).minindex < length(Tracks(i).X)
                Tracks(i).X = Tracks(i).X(Tracks(i).minindex:end);
                Tracks(i).Y = Tracks(i).Y(Tracks(i).minindex:end);
            else
                DelObjects(i) = 1;
            end
        end
end


function [type, Tracks, event]=SetType(PlotGrowingTags) %PlotGrowingTags is needed because of the event plot
if PlotGrowingTags 
    plottag = 1;
else
    plottag = 4; %this is a code (see fJKSegment.m))
end
hDynamicFilamentsGui = getappdata(0,'hDynamicFilamentsGui');
Options = getappdata(hDynamicFilamentsGui.fig,'Options');
if ~isempty(strfind(Options.lPlot_XVar.print, 'MAP')) || ~isempty(strfind(Options.lPlot_YVar.print, 'MAP'))
    OnlyWithIntensity = 1;
else
    OnlyWithIntensity = 0;
end
if ~isempty(strfind(Options.lPlot_XVar.print, 'custom')) || ~isempty(strfind(Options.lPlot_YVar.print, 'custom'))
    OnlyWithCustomData = 1;
else
    OnlyWithCustomData = 0;
end
Tracks = getappdata(hDynamicFilamentsGui.fig,'Tracks');
if Options.cOnlySelected.val
    Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
    selected=get(hDynamicFilamentsGui.lSelection,'Value');
    selected=unique(selected);
    selected=selected(logical(selected));
    Objects = Objects(selected);
    selected_tracks = [];
    for m = 1:length(Objects)
        selected_tracks = vertcat(selected_tracks, Objects(m).SegTagAuto(:,5));
    end
    selected_tracks = unique(selected_tracks);
    Tracks = Tracks(selected_tracks(logical(selected_tracks)));
end
type={Tracks.Type};
event=[Tracks.Event];
distance_event_end=[Tracks.DistanceEventEnd];
file={Tracks.File};
track_id=1:length(type);
for i=1:length(type)
    if floor(event(i))~=plottag || size(Tracks(i).Data, 1) < Options.eMinLength.val
        track_id(i)=0;
        continue
    end
    if OnlyWithIntensity
        if Tracks(i).HasIntensity==0
            track_id(i)=0;
            continue
        end
    end
    if OnlyWithCustomData
        if Tracks(i).HasCustomData==0
            track_id(i)=0;
            continue
        end
    end
    type{i}=[type{i} ' tag' num2str(event(i))];
    type{i}=strrep(type{i}, 'single400', 'single');
    type{i}=strrep(type{i}, '4.8', '4');
    type{i}=strrep(type{i}, '4.9', '4');
    type{i}=strrep(type{i}, 'tag4', '\downarrow');
    type{i}=strrep(type{i}, '1.8', '1');
    type{i}=strrep(type{i}, '1.9', '1');
    type{i}=strrep(type{i}, 'tag1', '\uparrow');
    switch Options.lGroup.val
        case 1
            prepend = '';
        case 2
            splitstr = strsplit(file{i},'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}  ' \_ '];
            else
                prepend=[splitstr{2}  ' \_ '];
            end
        case 3
            splitstr = strsplit(file{i},'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}(7:8) ' \_ ' splitstr{2} ' \_ '];
            else
                prepend=[splitstr{2} ' \_ ' splitstr{1} ' \_ '];
            end
        case 4
            prepend = '';
            type{i} = 'everything';
    end
    type{i}=[prepend type{i}];
    if (distance_event_end(i)>Options.eRescueCutoff.val||floor(event(i))~=4)&&abs(mod(event(i),1)-0.85)<0.1
        if abs(mod(event(i),1)-0.85)<0.1
            event(i)=2; %events which had not been recorded
        else
            event(i)=1;
        end
        if Options.cPlotEventsAsSeperateTypes.val
            type{i}=[type{i} '*'];
        end
    else
        event(i)=0;
    end
end
track_id=track_id(logical(track_id));
type=type(track_id);
event=event(track_id);
Tracks=Tracks(track_id);

% function vel=CalcVelocity(track)
% nData=size(track,1);
% if nData>1
%     vel=zeros(nData,1);
%     vel(1)=(track(2,2)-(track(1,2))) /...
%                  (track(2,1)-(track(1,1)));
%     vel(nData)=(track(nData,2)-(track(nData-1,2))) /...
%                  (track(nData,1)-(track(nData-1,1)));
%     for i=2:nData-1
%        vel(i)=(track(i,2)-(track(i-1,2))+track(i+1,2)-(track(i,2))) /...                    
%                      (track(i+1,1)-(track(i-1,1)));
%     end
% else
%     vel=nan(size(track,1),1);
% end

function SortFilaments()
hDynamicFilamentsGui=getappdata(0,'hDynamicFilamentsGui');
months = {'JanFebMarAprMayJunJulAugSepOctNovDec'};
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
mode=get(hDynamicFilamentsGui.lSortFilaments,'Value');
if ~isempty(Objects)
    orderstr=cell(length(Objects),1);
    switch mode
        case 1
            for i=1:length(Objects)
                underscores = strfind(Objects(i).File, '_');
                datestr = Objects(i).File(underscores(1)+1:underscores(2)-1);
                day = datestr(1:2);
                if ~isempty(strfind(day, ' '))
                    day = ['0' day(1)];
                end
                month = strfind(months, datestr(3:5));
                monthstr = int2str(month{1});
                if length(monthstr) == 1
                    monthstr = ['0' monthstr];
                end
                orderstr{i} = [datestr(6:7) monthstr day];
            end
            [~, order] = sort(orderstr);
        case 2
            [~, order] = sort({Objects.Type});
    end
    Objects = Objects(order);
end
setappdata(hDynamicFilamentsGui.fig,'Objects',Objects);
UpdateOptions();

function EventPlot(group, cutoff)
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
PlotGrowing=[1 0];
for i=1:2
    [type, Tracks, event]=SetType(PlotGrowing(i));
    uniquetypes=unique(type, 'stable');
    NEvents=zeros(length(uniquetypes),1);
    sumTime=zeros(length(uniquetypes),1);
    subplot(2,2,2*(i-1)+1)
    hold on;
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        plot([0.5 length(uniquetypes) + 0.5] , [0 0], 'k--')
        ylabel('Catastrophe distance to seed [nm]');
    else
        plot([0.5 length(uniquetypes) + 0.5] , [cutoff cutoff], 'r-')
        ylabel('Rescue distance to seed [nm]');
    end
    for n=1:length(Tracks)
        typenum=find(strcmp(uniquetypes, type{n}));
        if ~isempty(Tracks(n).Data)
            print_str = [int2str(Tracks(n).MTIndex) '/' int2str(Tracks(n).TrackIndex)];
            if event(n)
                NEvents(typenum)=NEvents(typenum)+1;
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','green');
                plot(typenum, Tracks(n).Data(end,2), 'Color','green', 'LineStyle', 'none', 'Marker','o');
            else
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','black');
                plot(typenum, Tracks(n).Data(end,2), 'Color','black', 'LineStyle', 'none', 'Marker','o');
            end
            sumTime(typenum)=sumTime(typenum)+Tracks(n).Duration/60;
        end
    end
    set(gca,'XTick',1:length(uniquetypes));
    set(gca,'xticklabel',uniquetypes);
    set(gca, 'Ticklength', [0 0])
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    subplot(2,2,2*(i-1)+2)
    fEvents=NEvents./sumTime;
    bar(fEvents(1:end),'stacked', 'r');
    for j=1:length(uniquetypes)
        if fEvents(j)
            text(j, fEvents(j)/2, {[num2str(fEvents(j), 2) ' /min'], ['N=' num2str(NEvents(j))], [num2str(sumTime(j),'%1.1f') ' min']}, 'HorizontalAlignment', 'center');
        else
            text(j, fEvents(j)/2, ['0 in ' num2str(sumTime(j),'%1.1f') ' min'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
    end
    set(gca,'XTick',1:length(uniquetypes));
    set(gca,'xticklabel',uniquetypes);
    set(gca, 'Ticklength', [0 0])
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        ylabel('Catastrophe frequency [per s]');
    else
        ylabel('Rescue frequency [per s]');
    end
end

function label = get_label(Options, isX)
if isX
    unit = Options.lPlot_XVar.str;
    title = Options.lPlot_XVar.print;
    methodstrtmp = Options.lMethod_TrackValue.print;
else
    unit = Options.lPlot_YVar.str;
    title = Options.lPlot_YVar.print;
    methodstrtmp = Options.lMethod_TrackValueY.print;
end
methodstr=methodstrtmp(1:strfind(methodstrtmp,'(')-2);
if isempty(methodstr)
    methodstr=methodstrtmp;
end
if Options.cPlotGrowingTracks.val==1
    label=[title ' (' methodstr '). Only tracks > 100s evaluated)'  ' [' unit ']'];
else
    label=[title ' (' methodstr ')' ' [' unit ']'];
end

function [x_vec, y_vec] = get_plot_vectors(Options, AnalyzedTracks, xy)
vector = cell(1,2);
selected_vars = {Options.lPlot_XVar.val, Options.lPlot_YVar.val};
for m = xy
    vector{m} = nan(length(AnalyzedTracks),1);
    for n = 1:length(AnalyzedTracks) % {'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'}
        switch Options.lMethod_TrackValue.val
            case 1
                vector{m}(n) = nanmedian(AnalyzedTracks(n).Data(:,selected_vars{m}));
            case 2
                vector{m}(n) = nanmean(AnalyzedTracks(n).Data(:,selected_vars{m}));
            case 3
                vector{m}(n) = AnalyzedTracks(n).Data(end,selected_vars{m}) - AnalyzedTracks(n).Data(1,selected_vars{m});
            case 4
                vector{m}(n) = min(AnalyzedTracks(n).Data(:,selected_vars{m}));
            case 5
                vector{m}(n) = max(AnalyzedTracks(n).Data(:,selected_vars{m}));
            case 6
                vector{m}(n) = std(AnalyzedTracks(n).Data(:,selected_vars{m}));
            case 7
                if selected_vars{m} == 3
                    vector{m}(n) = AnalyzedTracks(n).Velocity;
                else
                    vector{m}(n) = sum(AnalyzedTracks(n).Data(:,selected_vars{m}));
                end
        end
    end
end
x_vec = vector{1};
y_vec = vector{2};

function AgainstOtherMTTracksPlot(Options, ChosePlusTracks, ChosePreviousTrack)
hold on
[type, AnalyzedTracks, ~]=SetType(Options.cPlotGrowingTracks.val);
if Options.cPlotGrowingTracks.val==1
    LongTracks=[AnalyzedTracks.Duration]>100;
    AnalyzedTracks=AnalyzedTracks(LongTracks);
    type=type(LongTracks);
end
if Options.cPlotGrowingTracks.val && ~ChosePlusTracks
    [~, AnalyzedOtherTracks, ~]=SetType(0);
elseif (Options.cPlotGrowingTracks.val && ChosePlusTracks) || (~Options.cPlotGrowingTracks.val && ~ChosePlusTracks)
    AnalyzedOtherTracks = AnalyzedTracks;
elseif ~Options.cPlotGrowingTracks.val && ChosePlusTracks
    [~, AnalyzedOtherTracks, ~]=SetType(1);
end
[~, type_id, track_type_id] = unique(type);
[x_vec, ~] = get_plot_vectors(Options, AnalyzedTracks, 1);
[~, other_y_vecs] = get_plot_vectors(Options, AnalyzedOtherTracks, 2);
MT_indices = [AnalyzedOtherTracks.MTIndex];
if ~ChosePreviousTrack
    for m = 1:length(x_vec)
        track_indices = find(MT_indices == AnalyzedTracks(m).MTIndex);
        same_MT_vecs = other_y_vecs(track_indices);
        y_vec(m) = mean(same_MT_vecs);
    end
end
fJKscatterboxplot(x_vec, y_vec, track_type_id');
xlabel(get_label(Options, 1));
ylabel(get_label(Options, 0));
Legend = type(type_id);
legend(Legend{:});
hold off


function TrackXYPlot(Options)
hold on
[type, AnalyzedTracks, ~]=SetType(Options.cPlotGrowingTracks.val);
if Options.cPlotGrowingTracks.val==1
    LongTracks=[AnalyzedTracks.Duration]>100;
    AnalyzedTracks=AnalyzedTracks(LongTracks);
    type=type(LongTracks);
end
[~, type_id, track_type_id] = unique(type);
[x_vec, y_vec] = get_plot_vectors(Options, AnalyzedTracks, 1:2);
fJKscatterboxplot(x_vec, y_vec, track_type_id');
xlabel(get_label(Options, 1));
ylabel(get_label(Options, 0));
Legend = type(type_id);
legend(Legend{:});
hold off

function [middlex, middley, middlez] = histcounts2(plotx, ploty, plotz)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
hDynamicFilamentsGui=getappdata(0,'hDynamicFilamentsGui');
binwidth=str2double(get(hDynamicFilamentsGui.eDistanceWeight, 'String'));
plotx=plotx(~isnan(plotx));
limits=[min(plotx) max(plotx)];
span=ceil((limits(2)-limits(1))/binwidth)*(binwidth);
edges=(-span/2:binwidth:span/2)+mean(limits);
[~, edges, xid] = histcounts(plotx,edges);
binvecy=cell(numel(edges)-1,1);
binvecz=cell(numel(edges)-1,1);
for m=1:length(xid)
    if isempty(binvecy{xid(m)})
        binvecy{xid(m)}=ploty(m);
        binvecz{xid(m)}=plotz(m);
    else
        binvecy{xid(m)}=[binvecy{xid(m)}; ploty(m)];
        binvecz{xid(m)}=[binvecz{xid(m)}; plotz(m)];
    end
end
middlex=edges(1:end-1)+diff(edges)/2;
middlex=middlex(~cellfun(@isempty, binvecz));
binvecy=binvecy(~cellfun(@isempty, binvecy));
binvecz=binvecz(~cellfun(@isempty, binvecz));
middley=zeros(1,length(binvecy));
middlez=zeros(1,length(binvecz));
for m=1:length(binvecy)
    middley(m)=nanmean([binvecy{m}]);
    middlez(m)=nanmean([binvecz{m}]);
end

function IntensityVsDistWeightedVel(Options)
[type, Tracks, events]=SetType(Options.cPlotGrowingTracks.val);
for i=1:length(Tracks)
    Data=Tracks(i).Data;
    [middlex, middley, middlez] = histcounts2(Data(:,2), Data(:,3), Data(:,4));
    middley=middley(~isnan(middley));
    middlez=middlez(~isnan(middley));
    Tracks(i).X = middley';
    Tracks(i).Y = middlez';
end
Options.lPlot_XVar.print = 'Distance weighted Velocity (no subsegmenting/smoothing)';
Options.lPlot_XVar.str = '1';
Options.lPlot_YVar.print = 'MAP count';
Options.lPlot_YVar.str = '1';
fJKplotframework(Tracks, type, 0, events, Options);


function FilamentEndPlot(hDynamicFilamentsGui, has_err_fun_format)
Options = getappdata(hDynamicFilamentsGui.fig,'Options');
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
l = Objects(1).Custom.options_custom.help_get_tip_kymo.ExtensionLength;
[type, Tracks, events]=SetType(Options.cPlotGrowingTracks.val);
for n = 1:length(Tracks)
    Tracks(n).X = Tracks(n).Data(:, 6); %Frames from .Data Container
    Tracks(n).Y = Tracks(n).Data(:, 6);
end
[Tracks, DelObjects] = SelectSubsegments(Tracks, Options);
Tracks(DelObjects) = [];
events(DelObjects) = [];
type(DelObjects) = [];
Tracks = rmfield(Tracks, 'Data');
for n = 1:length(Tracks)
    frames = Tracks.X;
    X_cell = cell(length(frames),1);
    Y_cell = cell(length(frames),1);
    for p = 1:length(frames)
        data = Objects(Tracks(n).MTIndex).Custom.CustomData{p};
        Y_cell{p} = (data(1:min(15+l+1, length(data))))';
        if isnan(Y_cell{p})
            Y_cell{p} = [];
            X_cell{p} = [];
        end
        if has_err_fun_format
            Y_cell{p}=(Y_cell{p}-min(Y_cell{p}))/(max(Y_cell{p})-min(Y_cell{p})); 
            Y_cell{p}=(Y_cell{p}-0.5);
            Y_cell{p}=Y_cell{p}*1.99;
        end
        X_cell{p} = (-l:-l+length(Y_cell{p})-1)';
    end
    Tracks(n).X = vertcat(X_cell{:});
    Tracks(n).Y = vertcat(Y_cell{:});
end
Options.lPlot_XVar.print = 'Arc length away from plus end';
Options.lPlot_XVar.str = 'pixels';
if has_err_fun_format
    Options.lPlot_YVar.print = 'Intensity in error function format';
    Options.lPlot_YVar.str = '1';
    Options.FilamentEndPlot.has_err_fun_format = 1;
else
    Options.lPlot_YVar.print = 'Intensity';
    Options.lPlot_YVar.str = 'AU';
    Options.FilamentEndPlot.has_err_fun_format = 0;
end
fJKplotframework(Tracks, type, 0, events, Options);

function BoxPlot(Options)
hold on;
[type, AnalyzedTracks, ~]=SetType(Options.cPlotGrowingTracks.val);
if Options.cPlotGrowingTracks.val==1
    LongTracks=[AnalyzedTracks.Duration]>100;
    AnalyzedTracks=AnalyzedTracks(LongTracks);
    type=type(LongTracks);
end
[x_vec, ~] = get_plot_vectors(Options, AnalyzedTracks, 1);
if isempty(x_vec)
    text(0.3,0.5,'No data or path available for any objects','Parent','FontWeight','bold','FontSize',16);
    set('Visible','off');
    legend('off');
else
    [~, type_id, track_type_id] = unique(type, 'stable');
    b=boxplot(x_vec, type);
    for j=1:length(type_id)
        type_datavec=x_vec(track_type_id == j);
        plot_x = repmat(j, size(type_datavec)) + (rand(size(type_datavec))-0.5)./2.2;
        plot(plot_x, type_datavec, 'o', 'Color', [217;95;2]/255);
        text(j,nanmean(type_datavec),{num2str(median(type_datavec),3), ['N = ' num2str(length(type_datavec))]}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    set(gca,'XTickLabel','');
    set(gca, 'XTickLabelMode','manual');
    hxt = get(gca, 'XTick');
    ypos = min(ylim) - diff(ylim)*0.05;
    newtext = text(hxt, ones(1, length(type_id))*ypos, type(type_id), 'HorizontalAlignment', 'center');
    if (length(type_id)>2&&Options.lGroup.val>1)||length(type_id)>3
        set(newtext, 'rotation', 15);
    end
    h = findobj(b,'tag','Outliers');
    set(h,'Visible','off');
    ylabel(get_label(Options, 1));
end
hold off

function DataPlot(hDynamicFilamentsGui)
Objects = getappdata(hDynamicFilamentsGui.fig,'Objects');
hasvelocity=nan(length(Objects),1);
group=cell(length(Objects),1);
grouping=get(hDynamicFilamentsGui.lGroup, 'Value');
for n = 1:length(Objects) 
    splitstr = strsplit(Objects(n).File,'_');
    switch grouping
        case 1
            prepend = '';
        case 2
            if length(splitstr{1})>3
                prepend=splitstr{1};
            else
                prepend=splitstr{2};
            end
        case 3
            if length(splitstr{1})>3
                prepend=[splitstr{1}(7:8) '-' splitstr{2}];
            else
                prepend=[splitstr{2} ' - ' splitstr{1}];
            end
    end
    group{n}=[prepend ' \_ ' Objects(n).Type];
    hasvelocity(n) = ~all(isnan(Objects(n).Velocity(:,get(hDynamicFilamentsGui.lMethod_TrackValue, 'Value'))));
    duration(n) = Objects(n).Duration;
    disregard(n) = Objects(n).Disregard;
end
[uniquegroup]=unique(group, 'stable');
MTs=ones(length(uniquegroup),2);
TotalDisregard=zeros(length(uniquegroup),2);
TotalDuration=zeros(length(uniquegroup),2);
DurationKept=zeros(length(uniquegroup),2);
for n = 1:length(uniquegroup)
    id=cellfun(@(x) strcmp(x,uniquegroup(n)), group);
    MTs(n,1)=sum(hasvelocity(id));
    MTs(n,2)=length(hasvelocity(id))-MTs(n,1);
    TotalDisregard(n) = sum(disregard(id))/60;
    TotalDuration(n) = sum(duration(id))/60;
    DurationKept(n) = TotalDuration(n)/(TotalDuration(n)+TotalDisregard(n))*100;
end
bar(MTs,'stacked');
for j=1:length(uniquegroup)
    if DurationKept(j)>60
        text(j, MTs(j,1)/2, {['N = ' int2str(MTs(j,1))], ['Evaluated: ' int2str(TotalDuration(j)) ' min'], ['Disregarded: ' int2str(TotalDisregard(j)) ' min'], ['Yield: ' int2str(DurationKept(j)) '%']}, 'HorizontalAlignment', 'center', 'Color', 'w');
    else
        text(j, MTs(j,1)/2, {['N = ' int2str(MTs(j,1))], ['Evaluated: ' int2str(TotalDuration(j)) ' min'], ['Disregarded: ' int2str(TotalDisregard(j)) ' min'], ['Yield: ' int2str(DurationKept(j)) '%']}, 'HorizontalAlignment', 'center', 'Color', 'r');
    end
    if MTs(j,2)
        text(j, MTs(j,1)+MTs(j,2)/2, {['N = ' int2str(MTs(j,2))]}, 'HorizontalAlignment', 'center');
    end
end
set(gca,'XTick',1:length(uniquegroup));
set(gca,'xticklabel',uniquegroup);
if length(uniquegroup)>2
    set(gca,'XTickLabelRotation',15);
end
ylabel('Number of Microtubules (yellow: no dynamics)');