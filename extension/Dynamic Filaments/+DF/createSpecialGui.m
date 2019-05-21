function [ hDFGui ] = createSpecialGui(hDFGui)
%CREATEDFGUI Summary of this function goes here
%   Detailed explanation goes here
switch hDFGui.mode
    case 1
        hDFGui.Segment = @DF.segmentPatchesTIF;
    case 2
hDFGui.Segment = @DF.segmentFIESTAFils;
c = get(hDFGui.fig,'Color');

tooltipstr=sprintf(['Minimum distance filament has to shrink in order for it to count as a catastrophe. To determine where shrinking segments are to be found.\n' ...
    'Only if the MT monotonously shrinks that distance it can be considered a shrinking segment (other condition see edit box to the right).']);

hDFGui.tMinDist = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.825 0.3 0.125],'String','Min Shrinkage Distance:','Style','text','Tag','tIntensity','HorizontalAlignment','left');  

hDFGui.eMinDist = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.3 0.9 .1 .05],'String','400','Style','edit','Fontsize',10,'BackgroundColor','white',...
                                'UserData', 'nm', 'Tag','eMinDist','Value',0,'Enable','on'); 

tooltipstr=sprintf(['Maximum rebound. To determine where shrinking segments are to be found.\n' ...
    'The bigger this fraction, the more small shrinkage segments you will "discover" due to noise in the data.']);

hDFGui.eMaxRebound = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.45 0.9 .1 .05],'Tag','eMaxRebound','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', '1', 'String','0.15','BackgroundColor','white','HorizontalAlignment','center');  

hDFGui.tMaxTimeDiff = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.775 0.3 0.125],'String','Max time difference:','Style','text','Tag','tMaxTimeDiff','HorizontalAlignment','left');  

tooltipstr=sprintf(['If two points are further apart in time than this value [in seconds] they are not joined into one track but seperated.\n' ...
     'This only works at borders of segments. If a shrinkage segment follows a growth segment, a catastrophe will be assumed in between, but this shrinkage track will not show up in plots with references to start.']);

hDFGui.eMaxTimeDiff = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.3 0.85 .1 .05],'Tag','eMaxTimeDiff','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 's','String','20','BackgroundColor','white','HorizontalAlignment','center');    


hDFGui.tBorders = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.725 0.225 0.125],'String','Track borders:','Style','text','Tag','tVelocityCutoff','HorizontalAlignment','left'); 

tooltipstr=sprintf(['Max step size. To determine the borders of a shrinking segment.\n' ...
    'If a step is above this threshold, the track is terminated (starts from point with minimum velocity outwards).\n' ...
    'Important: The track is not terminated if the condition of the next edit box is fulfilled (see tooltip) \n' ...
    'Effects can be seen in the plots of each track (just try it). The higher this value, the longer the tracks.']);

hDFGui.eMinXChange = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[0.3 0.8 .1 .05],'Tag','eMinXChange','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', 'nm','String','0','BackgroundColor','white','HorizontalAlignment','center');  

tooltipstr=sprintf(['Min step factor. To determine the borders of a shrinking segment.\n' ...
    'If a step in question times the factor given in this box is completely offset by the next step, the track is not terminated at that step.\n' ...
    'The bigger this number, the shorter the tracks.']);

hDFGui.eMinXFactor = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.45 0.8 .1 .05],'Tag','eMinXFactor','Fontsize',10,'TooltipString', tooltipstr,...
                                         'UserData', '1','String','4','BackgroundColor','white','HorizontalAlignment','center');            

hDFGui.tIntensity = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.675 0.225 0.125],'String','Pixels from end:','Style','text','Tag','tIntensity','HorizontalAlignment','left');   

tooltipstr = 'How many pixels from MT end to evaluate for GFP intensity calculation. Only applies to intensity/MAP count plots.';
hDFGui.eIevalLength = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.3 .75 .1 .05],'String','3','Style','edit','Fontsize',10,...
                                'UserData', 'pixels','BackgroundColor','white','Tag','eIevalLength','Value',0,'Enable','on');            

tooltipstr = sprintf('Border of the first subsegment. The first point with a velocity higher than x%% of the maximum velocity is part of the middle segment.\n Set to 0 to save computation time.');
hDFGui.eSubStart = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.3 .7 .1 .05],'String','20','Style','edit',...
                                'UserData', '1','Fontsize',10,'BackgroundColor','white','Tag','eSubStart','Value',0,'Enable','on');            
% tooltipstr = '.';
% hDFGui.eSubMiddle = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
%                                 'Position',[.4 .7 .1 .05],'String','10','Style','edit','Fontsize',10,'BackgroundColor','white','Tag','eIevalLength','Value',0,'Enable','on');            
tooltipstr = sprintf('Border of the last subsegment. The first point (backwards) with a velocity higher than x%% of the maximum velocity is part of the middle segment.\n Set to 0 to save computation time.');
hDFGui.eSubEnd = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.45 .7 .1 .05],'String','20','Style','edit','Fontsize',10,...
                                'UserData', '1','BackgroundColor','white','Tag','eSubEnd','Value',00,'Enable','on');            

tooltipstr=sprintf(['Shrinking segments ending below this value are considered rescues (except if at end of movie).\n Growing tracks ending, shrinking tracks starting below this distance are discarded.\n' ...
    'Red line in rescue plot and the track plot (if within y limits)']);

hDFGui.tCutoffs = uicontrol('Parent',hDFGui.pOptions,'Units','normalized','BackgroundColor',c,...
 'Position',[0.05 0.65 0.65 0.05],'String','Cutoffs:','Style','text','Tag','tRescueCutoff','HorizontalAlignment','left'); 

hDFGui.eRescueCutoff = uicontrol('Parent',hDFGui.pOptions,'Style','edit','Units','normalized','Callback','fJKDynamicFilamentsGui(''SetTable'');',...
                                         'Position',[.3 .65 .1 .05],'Tag','eRescueCutoff','Fontsize',10, 'TooltipString', tooltipstr,...
                                         'UserData', 'nm', 'String','314','BackgroundColor','white','HorizontalAlignment','center');          

tooltipstr = sprintf(['Within this distance to the seed, points are not considered for growth segments (all points between first and last occurence of points within this range in nm).' ...
    '']);
hDFGui.eDisregard = uicontrol('Parent',hDFGui.pOptions,'TooltipString', tooltipstr, 'Units','normalized',...
                                'Position',[.45 .65 .1 .05],'String','157','Style','edit','Fontsize',10,'BackgroundColor','white','Tag','eDisregard',...
                                'UserData', 'nm','Value',0,'Enable','on');          

% tooltipstr=sprintf(['Detects rescues within a shrinking segment. A rescue is given if a MT grows during shrinking (the surrounding steps are below the max step size).\nThese catastrophes are not considered for the catastrophe frequency plots!!!']);
%                            
% hDFGui.cDoubleCat = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
%                                          'Position',[.6 0.65 .4 .1],'Tag','cDoubleCat','Fontsize',10,'TooltipString', tooltipstr,...
%                                          'String','Catas after rescues','BackgroundColor',c,'HorizontalAlignment','center'); 

tooltipstr=sprintf('Tagged with 8 in the tag4/tag7 field');

hDFGui.cIncludeUnclearPoints = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.75 .75 .25 .05],'Tag','cIncludeUnclearPoints','Fontsize',10,'TooltipString', tooltipstr,...
                                         'String','Include unclear points','BackgroundColor',c,'HorizontalAlignment','center');       

tooltipstr=sprintf('Include points where the MT tip is not in a configuration according to its type. \n Tags in the tag5/tag8 field (0=according to type, 15=one MT less, 1=one MT more, 14=close to template tip');  

hDFGui.cIncludeNonTypePoints = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.75 .7 .25 .05],'Fontsize',10,'TooltipString', tooltipstr, 'Tag', 'cIncludeNonTypePoints',...
                                         'String','Include non-type datapoints','BackgroundColor',c,'HorizontalAlignment','center');       
tooltipstr=sprintf('Choose subsegmenting according to absolute velocities in nm/s');  

hDFGui.cAbsVelocity = uicontrol('Parent',hDFGui.pOptions,'Style','checkbox','Units','normalized',...
                                         'Position',[.75 .65 .25 .05],'Fontsize',10,'TooltipString', tooltipstr, 'Tag', 'cAbsVelocity',...
                                         'String','Absolute velocity','BackgroundColor',c,'HorizontalAlignment','center','Value', 1);       

    case 3
        hDFGui.Segment = @DF.segmentPatchesLines;
end

