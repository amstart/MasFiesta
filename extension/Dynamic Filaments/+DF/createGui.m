function [ output_args ] = createGui( varargin )
%CREATEGUI Summary of this function goes here
%   Detailed explanation goes here
global DFDir
if nargin == 0
    h=findobj('Tag','hDFGui');
    close(h)

    hDFGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','on','IntegerHandle','off','Name','Average Velocity',...
                          'NumberTitle','off','Position',[0.1 0.1 0.8 0.8],'HandleVisibility','callback','Tag','hDFGui',...
                          'Visible','off','Resize','on','Renderer', 'painters');

    if ispc
        set(hDFGui.fig,'Color',[236 233 216]/255);
    end
    try
        DFDir = 'Y:\Jochen';
    catch
    end
    hDFGui.mode = 0;
else
    hDFGui=getappdata(0,'hDFGui');
    children=get(hDFGui.fig, 'Children');
    delete(children);
    DF.Quicksave(1);
end


c = get(hDFGui.fig,'Color');
                  
hDFGui.pPlotPanel = uipanel('Parent',hDFGui.fig,'Position',[0.4 0.6 0.575 0.395],'Tag','PlotPanel','BackgroundColor','white');

hDFGui.aPlot = axes('Parent',hDFGui.pPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','aPlot','TickDir','in');

hDFGui.pVelPlotPanel = uipanel('Parent',hDFGui.fig,'Position',[0.4 .005 0.575 0.3],'Tag','VelPlotPanel','BackgroundColor','white');

hDFGui.pIPlotPanel = uipanel('Parent',hDFGui.fig,'Position',[0.4 .305 0.575 0.295],'Tag','VelPlotPanel','BackgroundColor','white');

hDFGui.aVelPlot = axes('Parent',hDFGui.pVelPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','VelPlot','TickDir','in');

hDFGui.aIPlot = axes('Parent',hDFGui.pIPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','aIPlot','TickDir','in');

hDFGui.lSelection = uicontrol('Parent',hDFGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','DF.Draw(getappdata(0,''hDFGui''));',...
                                   'Position',[0.025 0.6 0.35 0.39],'String','','Style','listbox','Value',1,'Tag','lSelection','min',0,'max',10);
                    
hDFGui.bLegend = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''Legend'');',...
                                   'Position',[0.025 0.57 0.05 0.025],'String','Legend','Style','pushbutton','Tag','bLegend');      
                               
tooltipstr=sprintf(['Order objects by...']);

hDFGui.lSortFilaments = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SortFilaments'',getappdata(0,''hDFGui''));',...
                            'Position',[0.1 0.565 0.05 0.025],'Fontsize',10,'BackgroundColor','white','String',{'By Date','By Type', 'Order As Loaded'},'Value',3,'Style','popupmenu','Tag','lSortFilaments','Enable','on','TooltipString', tooltipstr);   
                        
hDFGui.bSelectAll = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.17 0.57 0.05 .025],'Tag','bSelectAll','Fontsize',10,...
                              'String','Select All','Callback','fJKDynamicFilamentsGui(''Select'');');   
                          
hDFGui.bIntoWorkSpace = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.25 0.57 0.05 .025],'Tag','bSelectAll','Fontsize',10,...
                              'String','Into Workspace','Callback','fJKDynamicFilamentsGui(''Workspace'');');   
                          
hDFGui.bDelete = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.325 0.57 0.05 .025],'Tag','bDelete','Fontsize',10,...
                              'String','Delete Selected','Callback','fJKDynamicFilamentsGui(''Delete'');');    
                          
hDFGui.bCustom = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''CustomPlot'');',...
                                   'Position',[0.9775 0.9 0.02 0.03],'String','custom','Style','pushbutton','Tag','bCustomPlot');   
                          
hDFGui.bSurf = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SurfPlot'');',...
                                   'Position',[0.9775 0.8 0.02 0.03],'String','surf','Style','pushbutton','Tag','bSurf');   
                          
hDFGui.bTIF = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.7 0.02 0.03],'String','tif','Style','pushbutton','Tag','bTIF');   
                               
hDFGui.bPDF = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.6 0.02 0.03],'String','pdf','Style','pushbutton','Tag','bTIF');   
                               
hDFGui.bTXT = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.5 0.02 0.03],'String','doc','Style','pushbutton','Tag','btxt'); 
                               
hDFGui.bLOCATION = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.4 0.02 0.03],'String','max','Style','pushbutton','Tag','bLOCATION');   
                               
hDFGui.bFOLDER = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.3 0.02 0.03],'String','folder','Style','pushbutton','Tag','bFOLDER');   
                               
hDFGui.bFIESTA = uicontrol('Parent',hDFGui.fig,'Units','normalized','Callback','fJKDynamicFilamentsGui(''OpenInfo'');',...
                                   'Position',[0.9775 0.2 0.02 0.03],'String','FIESTA','Style','pushbutton','Tag','bFIESTA'); 
     
hDFGui.pOptions = uipanel('Parent',hDFGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.025 0.07 0.35 0.5],'Tag','pOptions','BackgroundColor',c);
                         
tooltipstr = 'Useful for development and first thing you should try if the GUI appears to be broken.';        
                         
hDFGui.bRefreshGui = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''Create'', 1);',...
                                   'Position',[0.8 0.93 0.12 0.05],'String','Refresh GUI','Style','pushbutton','Tag','bRefreshGui','TooltipString', tooltipstr);  
                               
tooltipstr = 'Segments the currently loaded MTs according to the given parameters.';       
                               
hDFGui.bSegment = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions, 'FontSize', 15,...
                                   'Position',[0.65 0.85 0.15 0.05],'String','Segment','Style','pushbutton','Tag','bSegment','TooltipString', tooltipstr);    
                               
                               
hDFGui.tMethod_TrackValue = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.5 0.29 0.125],'String','Determine track value by:','Style','text','Tag','tVelocity','HorizontalAlignment','left');     

hDFGui.lMethod_TrackValue = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                            'Position',[0.3 0.5 0.3 0.125],'BackgroundColor','white','String',{'median', 'mean', 'end-start', 'minimum', 'maximum', 'median of difference', 'sum or linear fit (only for velocity)'},...
                            'Value',1,'Style','popupmenu','Tag','lMethod_TrackValue','Enable','on');   
                        
hDFGui.lMethod_TrackValueY = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                            'Position',[0.65 0.5 0.3 0.125],'BackgroundColor','white','String',{'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'},...
                            'Value',1,'Style','popupmenu','Tag','lMethod_TrackValueY','Enable','on');   
                        
tooltipstr=sprintf(['Applies a walking average to the X-Variable (number indicates over how many points). 1 = no smoothing. Only has effect on "X vs Y" and "Events along X during Y" plots.\n Uses "nanfastsmooth" (google it).']);
    
hDFGui.tSmooth = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.45 0.225 0.125],'String','Smooth:','Style','text','Tag','tSmooth','HorizontalAlignment','left'); 

hDFGui.eSmoothX = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[0.3 0.53 .05 .04],'Tag','eSmoothX','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'kernel width','String','1','BackgroundColor','white','HorizontalAlignment','center');  
                                     
tooltipstr=sprintf(['Affects how the current MT is plotted in the panels to the right (distance, intensity and velocity are smoothed).\n'...
    'Applies a walking average to the Y-Variable (number indicates over how many points). 1 = no smoothing. Only has effect on "X vs Y" and "Events along X during Y" plots.\n Uses "nanfastsmooth" (google it).']);
                                     
hDFGui.eSmoothY = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized','Callback','fJKDynamicFilamentsGui(''DF.Draw'',getappdata(0,''hDFGui''));',...
                                         'Position',[0.4 0.53 .05 .04],'Tag','eSmoothY','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'kernel width','String','1','BackgroundColor','white','HorizontalAlignment','center');  

hDFGui.tChoosePlot = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.4 0.225 0.125],'String','Plot:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');     
hDFGui.bUpdatePlots = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                                   'Position',[0.15 0.45 0.12 0.05],'String','Update All','Style','pushbutton','Tag','bUpdatePlots');     
                               
tooltipstr=sprintf(['Set the X variable.']); %lPlot_XVar and lPlot_YVar are set in DF.updateOptions()
                               
hDFGui.lPlot_XVar = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                            'Position',[0.3 0.4 0.2 0.125],'BackgroundColor','white', 'TooltipString', tooltipstr,'Style','popupmenu','Tag','lPlot_XVar','Enable','on');
                       

tooltipstr=sprintf(['Set the Y variable and plot (Either "X vs Y" or "Events along X during Y" have to be selected below).']);
                        
hDFGui.lPlot_YVar = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                            'Position',[0.55 0.4 0.2 0.125],'BackgroundColor','white', 'TooltipString', tooltipstr,'Style','popupmenu','Tag','lPlot_YVar','Enable','on');

          
hDFGui.lChoosePlot = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''SetMenu'',getappdata(0,''hDFGui''));', 'Value', 3,...
                            'Position',[0.3 0.35 0.3 0.125],'BackgroundColor','white','TooltipString', tooltipstr,'Style','popupmenu','Tag','lChoosePlot','Enable','on', ...
                            'String',{'X vs Y', 'Events along X during Y', 'Events', 'Box(X)', 'X vs Y (Tracks)', 'Dataset (rough)', 'Shape of Filament End', 'Plot X against Y of tracks of same MT', 'MAP vs distance weighted velocity'});
                        
hDFGui.bDoPlot = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback',@DF.updateOptions,...
                                   'Position',[0.65 0.4 0.12 0.05],'String','Plot','Style','pushbutton', 'FontSize', 15); 
                               
hDFGui.bDeletePlots = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Callback','fJKDynamicFilamentsGui(''DeletePlots'');',...
                                   'Position',[0.8 0.45 0.12 0.05],'String','Close All','Style','pushbutton'); 
                               
tooltipstr=sprintf(['When you have a plot open you can conveniently save it pressing "s".']);
                               
hDFGui.tQuickInfo = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c, 'TooltipString', tooltipstr,...
                             'Position',[0.8 0.4 0.65 0.03],'String','Save fig pressing "s"','Style','text','Tag','tIntensity','HorizontalAlignment','left');   
                         
hDFGui.tSubsegment = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.275 0.225 0.125],'String','Select segment(s):','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
                         
hDFGui.lSubsegment = uicontrol('Parent',hDFGui.pOptions,'Units','normalized',...
                            'Position',[0.3 0.29 0.3 0.125],'BackgroundColor','white','String',{'All','Beginning','Middle','End', 'Beginning and Middle', 'Middle and End', 'Middle to End'}, ...
                            'Style','popupmenu','Enable','on', 'Value', 1, 'Tag', 'lSubsegment');   

         
hDFGui.tPlotRef = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.225 0.225 0.125],'String','x axis reference:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
                         
hDFGui.mXReference = uicontrol('Parent',hDFGui.pOptions,'Units','normalized',...
                            'Position',[0.3 0.24 0.3 0.125],'BackgroundColor','white','String',{'No reference','To previous data point','To end (before events only)','To median', 'To track velocity (velocity only)','To start (all tracks)','To end (all tracks)'}, ...
                            'Style','popupmenu','Tag','mXReference','Enable','on', 'Value', 1); 
                        
tooltipstr=sprintf('Only plots data from selected Filaments (does not work for all plots).');
                                
hDFGui.cOnlySelected = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[0.65 0.35 0.15 0.05],'Tag','cOnlySelected','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Only Selected','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                                     
tooltipstr=sprintf('Plots a legend (does not work for all plots).');
                                
hDFGui.cLegend = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized', 'Tag', 'cLegend',...
                                         'Position',[0.65 0.3 0.15 0.05],'Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Legend','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                                     
tooltipstr=sprintf('Groups points of tracks which come from the same microtubule into one color and one legend entry.');
                                
hDFGui.cGroupIntoMTs = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized', 'Tag', 'cGroupIntoMTs',...
                                         'Position',[0.65 0.25 0.15 0.05],'Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Group Tracks','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 1);  

tooltipstr=sprintf('Plots data from untagged (growing) tracks.');
                                
hDFGui.cPlotGrowingTracks = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[0.85 0.35 0.2 0.05],'Tag','cPlotGrowingTracks','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Growing','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                        
hDFGui.tGroup = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.175 0.225 0.125],'String','Grouping:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
        
tooltipstr=sprintf(['Type&Day&Experiment is only necessary if there are experiments with the same movie number on different days.\n Month/Year only considered for Type&Day.']);

hDFGui.lGroup = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Style','popupmenu','Tag','lGroup','TooltipString', tooltipstr,...
                             'Position',[0.3 0.19 0.3 0.125],'BackgroundColor','white','String',{'Type','Type&Day','Type&Day&Experiment', 'Pool everything'}, 'Value',1);
                        
tooltipstr=sprintf(['Distinguishes between tracks (marked with *) with and without event in the end.']);
                                                    
hDFGui.cPlotEventsAsSeperateTypes = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.8 .3 .4 .05],'Tag','cPlotEventsAsSeperateTypes','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Distinguish events','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0); 

tooltipstr=sprintf(['Pools tracks with and without MAPs.']);
                                                    
hDFGui.lPoolMAPs = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.8 .25 .4 .05],'Tag','cPoolMAPs','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Pool w and w/o MAPs','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0); 
                                     
                                     
tooltipstr=sprintf(['Excludes first and last points of tracks for plots.']);
                                                                                         
hDFGui.cExclude = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.65 .175 .4 .05],'Tag','cExclude','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Also y reference','BackgroundColor',c,'HorizontalAlignment','center', 'Value', 0);  
                
hDFGui.tStat = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.1 0.225 0.125],'String','Additional Plots:','Style','text','Tag','tChoosePlot','HorizontalAlignment','left');    
        
tooltipstr=sprintf(['Not functional yet']);

hDFGui.lAdditionalPlots = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','Style','popupmenu','Tag','lAdditionalPlots','TooltipString', tooltipstr,...
                             'Position',[0.3 0.125 0.3 0.125],'BackgroundColor','white','String',{'None','QQ'}, 'Value',1);
                                         
tooltipstr=sprintf(['Takes out tracks with less points than given in the box.']);
                             
hDFGui.tMinLength = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.025 0.65 0.125],'String','Min Length:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 
                                     
hDFGui.eMinLength = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.3 .1 .1 .05],'Tag','eMinLength','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','2','BackgroundColor','white','HorizontalAlignment','center'); 
                                     
tooltipstr=sprintf(['Takes out tracks with less [seconds] duration than given in the box (growth tracks only).']);
                                     
hDFGui.eMinDuration = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.45 .1 .1 .05],'Tag','eMinDuration','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 's', 'String','15','BackgroundColor','white','HorizontalAlignment','center');    
                                     
tooltipstr=sprintf(['Bin width [nm] for plots which show distance weighted values (instead of frame weighted).']);

hDFGui.tDistanceWeight = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.75 0.025 0.65 0.125],'String','Dist bins:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 
                                     
hDFGui.eDistanceWeight = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.89 .1 .1 .05],'Tag','eDistanceWeight','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','20','BackgroundColor','white','HorizontalAlignment','center');                  

                                     
tooltipstr=sprintf(['Shows the track indices (the index of the track within the track structure, see code).']);
                                     
hDFGui.cshowTrackN = uicontrol('Parent',hDFGui.fig,'Style','checkbox','Units','normalized',...
                                         'Position',[.38 .75 .015 .02],'Tag','cshowTrackN','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','','BackgroundColor',c,'HorizontalAlignment','center','Callback','fJKDynamicFilamentsGui(''DF.Draw'',getappdata(0,''hDFGui''));');
                                     
hDFGui.bSave = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.025 .005 .06 .05],'Tag','bSave','Fontsize',12,...
                              'String','Save Links','Callback','fJKDynamicFilamentsGui(''Save'');');      
                          
hDFGui.bLoad = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.1 .005 .06 .05],'Tag','bLoad','Fontsize',12,...
                              'String','Load File','Callback','DF.Load();');         

hDFGui.bLoadFolder = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.18 .005 .05 .05],'Tag','bLoadFolder','Fontsize',12,...
                              'String','Load Folder','Callback','DF.LoadFolder();');     
                          
hDFGui.bLoadOptions = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.232 .03 .05 .023],'Tag','bLoadOptions','Fontsize',12,...
                              'String','Load Options','Callback',@LoadOptions);     
                          
hDFGui.bSaveOptions = uicontrol('Parent',hDFGui.fig,'Style','pushbutton','Units','normalized',...
                              'Position',[.232 .005 .05 .023],'Tag','bSaveOptions','Fontsize',12,...
                              'String','Save Options','Callback',@DF.updateOptions);     
                          
hDFGui.pLoadOptions = uipanel('Parent',hDFGui.fig,'Units','normalized','Title','What to load',...
                             'Position',[0.3 0.005 0.1 0.12],'Tag','pLoadOptions','BackgroundColor',c);
                          
hDFGui.cAllowUnknownTypes = uicontrol('Parent',hDFGui.pLoadOptions,'Units','normalized',...
                             'Position',[0.01 .85 1 0.2],'BackgroundColor',c,'Style','checkbox','Tag','cAllowUnknownTypes','String','Import tracks with ''unknown'' type');  
                          
hDFGui.cAllowWithoutReference = uicontrol('Parent',hDFGui.pLoadOptions,'Units','normalized',...
                             'Position',[0.01 .7 1 0.2],'BackgroundColor',c,'Style','checkbox','Tag','cAllowWithoutReference','String','Allow tracks without reference');  

hDFGui.cUsePosEnd = uicontrol('Parent',hDFGui.pLoadOptions,'Units','normalized',...
                            'Position',[0.01 .55 1 0.2],'BackgroundColor',c,'String','Use PosEnd instead of PosStart','Style','checkbox','Tag','cUsePosEnd','Enable','on');
                        
                                     
tooltipstr=sprintf(['If you have the intensities in extra files within the same folder as the original file, provide the filename here to load them (without .mat)']);
                                     
hDFGui.eLoadIntensityFile = uicontrol('Parent',hDFGui.pLoadOptions,'Style','edit','Units','normalized',...
                                         'Position',[.1 .3 0.8 .2],'Tag','eLoadIntensityFile','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', '.mat', 'String','','BackgroundColor','white','HorizontalAlignment','center');  
                                            
tooltipstr=sprintf(['If you have custom data you can add it to your objects here']);
                                     
hDFGui.bAppendCustomData = uicontrol('Parent',hDFGui.pLoadOptions,'Units','normalized','Callback', @DF.AddCustomData,...
                                         'Position',[.1 .05 0.8 .2],'Tag','bAppendCustomData','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'String','Append Custom Data','BackgroundColor',c,'HorizontalAlignment','center');    

if nargin == 0                                                                
    set(hDFGui.fig,'Visible','on');
    Objects = fDefStructure([], 'Filament');                                
    setappdata(hDFGui.fig,'Objects',Objects);
end
hDFGui.mode = 2;
[ hDFGui ] = DF.createSpecialGui(hDFGui);
setappdata(0,'hDFGui',hDFGui);
DF.updateOptions()