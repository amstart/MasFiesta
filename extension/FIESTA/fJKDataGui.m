function fJKDataGui(func,varargin)
%This is a modified version of fDataGui
switch (func)
    case 'Create'
%         try
            Create(varargin{1},varargin{2});
%         catch
%             return;
%         end
    case 'FixOrientation'
        FixOrientation(varargin{1});  
    case 'ShowTable'
        ShowTable(varargin{1});
    case 'Draw'
        Draw(varargin{1},varargin{2});
    case 'PlotXY'
        PlotXY(varargin{1});
    case 'Kymo'
        Kymo;
    case 'DeletePoints'
        DeletePoints(varargin{1});
    case 'DeleteObject'
        DeleteObject(varargin{1});
    case 'Navigation'
        Navigation(varargin{1});
    case 'Switch'
        Switch(varargin{1});   
    case 'FitMissingPoints'
        FitMissingPoints(varargin{:}); 
    case 'Tags'
        Tags(varargin{1});
    case 'ApplyTags'
        ApplyTags(varargin{1});
    case 'FlipTags'
        FlipTags(varargin{1});
    case 'Undo'
        Undo(varargin{1}); 
    case 'Split'
        Split(varargin{1});          
    case 'SelectAll'
        SelectAll(varargin{1});          
    case 'Drift'
        Drift(varargin{1});
    case 'XAxisList'
        XAxisList(varargin{:});        
    case 'CheckYAxis2'
        CheckYAxis2(varargin{1});              
    case 'bToggleToolCursor'
        bToggleToolCursor(varargin{1});  
    case 'bToolPan'
        bToolPan(varargin{1});
    case 'bToolZoomIn'
        bToolZoomIn(varargin{1});
    case 'Export'
        Export(varargin{1});
    case 'RefreshData'
        RefreshData(varargin{:});
    case 'ZoomIn'
        ZoomIn(varargin{:});
    case 'ExpandTrack'
        ExpandTrack(varargin{:});
    case 'SetChannel'
        SetChannel;
    case 'SetComments'
        SetComments;
    case 'AlignColor'
        AlignColor(varargin{1});
    case 'InterpolateTrack'
        InterpolateTrack(varargin{1});
    case 'SelectValues'
        SelectValues(varargin{1});
end

function hDataGui = Create(Type,idx)
global Molecule;
global Filament;
hDataGui=getappdata(0,'hDataGui');
hDataGui.BackUp=1;
hDataGui.Type=Type;
eNext='on';
if idx==1
    ePrevious='off';
else
    ePrevious='on';
end
if strcmp(Type,'Molecule')
    idx = min([idx length(Molecule)]);
    idx = max([1 idx]);
    Object=Molecule(idx);
    if idx==length(Molecule)
        eNext = 'off';
    end      
    refEnable = 'off';
else
    idx = min([idx length(Filament)]);
    idx = max([1 idx]);
    Object=Filament(idx);
    if idx==length(Filament)
        eNext = 'off';
    end
    refEnable = 'on';
end
if hDataGui.Extensions.JochenK.DynTags
    tagstring = {'Missed','Interpolated','Tag1','Tag2','Tag3','Tag4 or Tag7','Tag5 or Tag8','Tag6 or Tag9'};
else
    tagstring = {'Missed','Interpolated','Tag1','Tag2','Tag3','Tag4','Tag5','Tag6'};
end
hDataGui.Name = Object.Name;
hDataGui.idx=idx;
h=findobj('Tag','hDataGui');
if isempty(h) %JochenK: Changed arrangement of buttons slightly
    hDataGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name',Object.Name,...
                          'NumberTitle','off','HandleVisibility','callback','Tag','hDataGui',...
                          'Visible','off','Resize','on','WindowStyle','normal');
                      
    fPlaceFig(hDataGui.fig,'big');
    
    if ispc
        set(hDataGui.fig,'Color',[236 233 216]/255);
    end
    
    c = get(hDataGui.fig,'Color');

    hDataGui.pPlotPanel = uipanel('Parent',hDataGui.fig,'Position',[0.35 0.55 0.63 0.4],'Tag','PlotPanel','BackgroundColor','white');
    
    hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'Tag','Plot','NextPlot','add','TickDir','out','Layer','top',...
                          'XLimMode','manual','YLimMode','manual');
                      
    columnname = {'','','','','','','','','','',''};
    if mean(Object.Results(2:end,2)-Object.Results(1:end-1,2))<0.1
        columnformat = {'logical','numeric','bank','bank','bank','bank','bank','bank', 'bank', 'bank', 'char'};
    else
        columnformat = {'logical','numeric','short','bank','bank','bank','bank','bank', 'bank', 'bank', 'char'};
    end
    columneditable = logical([ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    
    hDataGui.tTable = uitable('Parent',hDataGui.fig,'Units','normalized','Position',[0.025 0.025 0.95 0.45],'Tag','tTable','Enable','on',...            
                              'ColumnName', columnname,'ColumnFormat', columnformat,'ColumnEditable', columneditable,'RowName',[]);

    hDataGui.tName = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'FontWeight','bold',...
                              'HorizontalAlignment','left','Position',[0.02 0.96 0.15 0.02],...
                              'String',Object.Name,'Style','text','Tag','tName','BackgroundColor',c);

    hDataGui.tFile = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'FontAngle','italic',...
                              'HorizontalAlignment','left','Position',[0.19 0.96 0.3 0.02],...
                              'String',Object.File,'Style','text','Tag','tFile','BackgroundColor',c);
                          
    tooltipstr=sprintf(['Comment this Object (saved in Object.Comments). \n' ...
    'If you write "ref:[name of reference]-", you can plot the distance to the referenced object. \n The start position of the reference will be subtracted from the start position of the object etc, for molecules it is always Results.\n' ...
    'You can also write -s, -c, -e or -r instead of - to enforce a certain reference point (the result of the current object is taken). Only works in 2D so far.']);
                          
    hDataGui.eComments = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'Callback','fJKDataGui(''SetComments'');',...
                              'HorizontalAlignment','left','Position',[0.51 0.955 0.3 0.03], 'TooltipString', tooltipstr,...
                              'String',Object.Comments,'Style','edit','Tag','eComments','BackgroundColor','white');
                          
    hDataGui.tIndex = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                'Position',[0.02 0.93 0.1 0.02],'String',['Index: ' num2str(idx)],'Style','text','Tag','tIndex','BackgroundColor',c);   
                    
    hDataGui.cAligned = uicontrol('Parent',hDataGui.fig,'Units','normalized','Position',[0.13 0.93 0.1 0.02],'TooltipString','Whether the object has been color aligned. Be careful with this in conjunction with Drift correction!','Callback','fJKDataGui(''AlignColor'',getappdata(0,''hDataGui''),0);',... %JochenK AlignColor
                                  'String','Aligned','Style','checkbox','BackgroundColor',c,'Tag','cAligned','Enable','on');   
    
    hDataGui.tChannel = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                'Position',[0.24 0.93 0.06 0.02],'String','Channel:','Style','text','Tag','tChannel','BackgroundColor',c);  
                           
    hDataGui.eChannel = uicontrol('Parent',hDataGui.fig,'Style','edit','Units','normalized',...
                                         'Position',[0.31 0.93 0.03 0.02],'Tag','eChannel','Fontsize',10,...
                                         'String',num2str(Object.Channel),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'Callback', 'fJKDataGui(''SetChannel'');');  

                  
    hDataGui.bPrevious = uicontrol('Parent',hDataGui.fig,'Style','pushbutton','Units','normalized','Callback','fJKDataGui(''Navigation'',-1);',...
                             'Position',[0.02 0.89 0.1 0.03],'String','Previous','Tag','bPrevious','Enable',ePrevious);
                         
    hDataGui.bDelete = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''DeleteObject'',getappdata(0,''hDataGui''));',...
                             'Position',[0.13 0.89 0.1 0.03],'String','Delete','Tag','bDelete');
   
    hDataGui.bNext = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Navigation'',1);',...
                             'Position',[0.24 0.89 0.1 0.03],'String','Next','Tag','bNext','Enable',eNext);

    hDataGui.cDrift = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Drift'',getappdata(0,''hDataGui''));',...
                                'Position',[0.02 0.855 0.12 0.02],'String','Correct for Drift','Style','checkbox','BackgroundColor',c,'Tag','cDrift','Value',Object.Drift);

    hDataGui.tReference = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                  'Position',[0.16 0.855 0.1 0.02],'String','Reference Point:','Style','text','Tag','tReference','BackgroundColor',c);
     
    hDataGui.lReference = uicontrol('Parent',hDataGui.fig,'TooltipString','Change reference point for this filament only', 'Units','normalized','Callback','fJKDataGui(''RefreshData'',getappdata(0,''hDataGui''),0);','Enable',refEnable,...
                                 'Style','popupmenu','FontSize',8,'Position',[0.26 0.863 0.07 0.02],'String',{'start', 'center', 'end'},'Tag','lReference','BackgroundColor','white', 'Value', 2);
            
    hDataGui.gColor = uibuttongroup('Parent',hDataGui.fig,'Title','Color','Tag','bColor','Units','normalized','Position',[0.02 0.75 0.15 0.1],'BackgroundColor',c);

    hDataGui.rBlue = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.725 0.4 0.25],...
                               'String','Blue','Style','radiobutton','BackgroundColor',c,'Tag','rBlue','UserData',[0 0 1]);

    hDataGui.rGreen = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.4 0.4 0.25],...
                                'String','Green','Style','radiobutton','BackgroundColor',c,'Tag','rGreen','UserData',[0 1 0]);

    hDataGui.rRed = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.025 0.025 0.4 0.25],...
                              'String','Red','Style','radiobutton','BackgroundColor',c,'Tag','rRed','UserData',[1 0 0]);

    hDataGui.rMagenta = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.725 0.5 0.25],...
                               'String','Magenta','Style','radiobutton','BackgroundColor',c,'Tag','rMagenta','UserData',[1 0 1]);

    hDataGui.rCyan = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.4 0.5 0.25],...
                                  'String','Cyan','Style','radiobutton','BackgroundColor',c,'Tag','rCyan','UserData',[0 1 1]);

    hDataGui.rPink = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.475 0.025 0.5 0.25],...
                                 'String','Pink','Style','radiobutton','BackgroundColor',c,'Tag','rPink ','UserData',[1 0.5 0.5]);

    set(hDataGui.gColor,'SelectionChangeFcn',@selcbk);

    set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));

    hDataGui.pTags = uipanel('Parent',hDataGui.fig,'Title','Edit Tags','Tag','bTags','Units','normalized','Position',[0.18 0.75 0.16 0.1],'BackgroundColor',c);
                 
    hDataGui.pPlot = uipanel('Parent',hDataGui.fig,'Title','Plot','Tag','gPlot','Position',[0.02 0.55 0.32 0.2],'BackgroundColor',c);

    hDataGui.tXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.8 0.33 0.18],...
                                'HorizontalAlignment','left','String','X Axis:','Tag','lXaxis','BackgroundColor',c);

    hDataGui.lXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized', 'Value', 2, 'Callback','fJKDataGui(''XAxisList'',getappdata(0,''hDataGui''), 0);',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.8 0.55 0.18],'Tag','lXaxis','BackgroundColor','white');

    hDataGui.tYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.6 0.33 0.18],...
                                'HorizontalAlignment','left','String','Y Axis (left):','Tag','lYaxis','BackgroundColor',c);

    hDataGui.pEdit = uipanel('Parent',hDataGui.fig,'Title','Edit Object','Tag','bTags','Units','normalized','Position',[0.225 0.2 0.12 0.245],'BackgroundColor',c,'Visible','off');
                 
    hDataGui.pCustom = uipanel('Parent',hDataGui.fig,'Title','Custom','Tag','bTags','Units','normalized','Position',[0.015 0.075 0.33 0.1],'BackgroundColor',c,'Visible','off');
                
    tooltipstr = sprintf(['The reference is what you provide in the "Comments" field. If nothing is there, the reference is the first frame in which you set the tag to 11 (tag3 if no dynamic filament tags are selected).' ...
    '\n If nothing is given at all, the reference is the frame when the filament is shortest (only with dynamic filament activated).']);
                            
    hDataGui.lYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fJKDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.6 0.55 0.18],'Tag','lYaxis','BackgroundColor','white', 'TooltipString', tooltipstr);                        

    hDataGui.cYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fJKDataGui(''CheckYAxis2'',getappdata(0,''hDataGui''));',...
                                'Position',[0.05 0.46 0.9 0.12],'String','Add second plot','Style','checkbox','BackgroundColor',c,'Tag','cYaxis2','Value',0,'Enable','off');

    hDataGui.tYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.26 0.33 0.18],...
                                'HorizontalAlignment','left','String','Y Axis (right):','Tag','lYaxis','Enable','off','BackgroundColor',c);

    hDataGui.lYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fJKDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',8,'Position',[0.4 0.26 0.55 0.18],'Tag','lYaxis2','Enable','off','BackgroundColor','white');                        

    hDataGui.bExport = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fJKDataGui(''Export'',getappdata(0,''hDataGui''));',...
                                 'FontSize',10,'Position',[0.05 0.1 0.9 0.14],'String','Export','Tag','bExport','UserData','Export');

    hDataGui.tPrint = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','BackgroundColor',c,...
                                'FontSize',8,'Position',[0.05 0.01 0.9 0.08],'String','(for printing use export to PDF)','Tag','tPrint');
    
    hDataGui.bSelectAll = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''SelectAll'',getappdata(0,''hDataGui''));',...
                             'Position',[0.13 0.48 0.1 0.025],'String','Select all','Tag','bSelectAll','UserData',1);                    
                         
    hDataGui.bClear = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''SelectAll'',getappdata(0,''hDataGui''));',...
                             'Position',[0.235 0.48 0.1 0.025],'String','Clear selection','Tag','bClear','UserData',0);                         
    
    hDataGui.bDeletePoints = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''DeletePoints'',getappdata(0,''hDataGui''));',...
                             'Position',[0.35 0.510 0.1 0.025],'String','Delete points','Tag','bDelete');
                         
    hDataGui.bSplit = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Split'',getappdata(0,''hDataGui''));',...
                             'Position',[0.455 0.510 0.1 0.025],'String','Create new track','Tag','bSplit');
                         
    tooltipstr=sprintf('Newly tracked points have the "missed" tag set.'); 
   
    hDataGui.bInsertPoints = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''FitMissingPoints'',getappdata(0,''hDataGui''));',...
                             'Position',[0.665 0.51 0.1 0.025],'String','Track missing frames','Tag','bInsertPoints','TooltipString', tooltipstr);
                         
    hDataGui.bSwitch = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Switch'',getappdata(0,''hDataGui''));',...
                                'Position',[0.56 0.51 0.1 0.025],'String','Switch MT orientation','Tag','bDelete');
                            
    hDataGui.tFrame = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                             'Position',[0.85 0.96 0.05 0.02],'String','Frame:','Style','text','Tag','tFrame','BackgroundColor',c);

    hDataGui.tFrameValue = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                                  'Position',[0.9 0.96 0.05 0.02],'String','','Style','text','Tag','tFrameValue','BackgroundColor',c);
                              
                              %JochenK
                              
    hDataGui.cTable = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''ShowTable'',getappdata(0,''hDataGui''));',...
                                'Position',[0.0025 0.2 0.02 0.025],'String','','Style','checkbox','BackgroundColor',c,'Tag','cTable','Value',0, 'TooltipString','Show table. Disable for more space for plotting and higher perfomance.');
                            
    hDataGui.bTag1 = uicontrol('Parent',hDataGui.pTags,'Units','normalized','TooltipString','Flip tag1 of selection (bit)','Callback','fJKDataGui(''FlipTags'',getappdata(0,''hDataGui''));',...
                                'Position',[0.4 0.7 0.2 0.25],'String','Tag1','Tag','bTag1', 'UserData', 3);
                            
    hDataGui.bTag2 = uicontrol('Parent',hDataGui.pTags,'Units','normalized','TooltipString','Flip tag2 of selection (bit)','Callback','fJKDataGui(''FlipTags'',getappdata(0,''hDataGui''));',...
                                'Position',[0.7 0.7 0.2 0.25],'String','Tag2','Tag','bTag2', 'UserData', 4);
                            
    hDataGui.tTags = uicontrol('Parent',hDataGui.fig,'Style','text','Units','normalized',...
                                         'Position',[0.35 0.48 0.1 0.025],'Tag','eTags','Fontsize',10,...
                                         'String','Active tag:','BackgroundColor',c,'HorizontalAlignment','center');  

    tagnumberstring = num2cell(0:15);                                 
    hDataGui.lTagNumber = uicontrol('Parent',hDataGui.pTags,'Style','popupmenu','Units','normalized','TooltipString','Tag to be applied to selection.',...
                                         'Position',[0.05 0.1 0.45 0.4],'Tag','eTags','Fontsize',9,...
                                         'String',tagnumberstring,'BackgroundColor','white','HorizontalAlignment','center');  
                                     
    hDataGui.bApplyTag = uicontrol('Parent',hDataGui.pTags,'Units','normalized','TooltipString','Apply selected tag. Only 0/1 for binary tags.','Callback','fJKDataGui(''ApplyTags'',getappdata(0,''hDataGui''));',...
                                'Position',[0.55 0.05 0.4 0.35],'String','Apply','Tag','bApplyTag');
   
    hDataGui.lTags = uicontrol('Parent',hDataGui.fig,'Style','popupmenu','Units','normalized','TooltipString','Active tag column for editing and plotting.',...
                                         'Position',[0.455 0.48 0.1 0.025],'Tag','eTags','Fontsize',9,'Callback','fJKDataGui(''RefreshData'',getappdata(0,''hDataGui''),-1);',...
                                         'String',tagstring,'BackgroundColor','white','HorizontalAlignment','center');  
                              
    tooltipstr=sprintf('Uses current options for kymographs. Reaches beyond the ends of filaments. Can be used for moving objects (assuming the move along a straight line).');                    
    hDataGui.bKymo = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Kymo'');',...
                                'Position',[0.875 0.51 0.075 0.025],'String','Kymograph','Tag','bKymo','TooltipString', tooltipstr);
                            
    tooltipstr=sprintf(['Tick to set the start and the end of the kymograph according to the current object.' ...
    '\nDo not forget to change this value back afterwards if you want to have a kymograph of all frames afterwards (in the "Scan" panel).']);                        
    hDataGui.cKymo = uicontrol('Parent',hDataGui.fig,'Units','normalized','TooltipString', tooltipstr,...
                                'Position',[0.955 0.51 0.0175 0.025],'String','','Style','checkbox','BackgroundColor',c,'Tag','cKymo','Value',0,'Enable','on');
                            
    tooltipstr='Provide evaluation length. Makes intensity available to plot on the y-axis.';       
                            
    hDataGui.bUndo = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fJKDataGui(''Undo'',getappdata(0,''hDataGui''));',...
                                'Position',[0.77 0.510 0.1 0.025],'String','Undo','Tag','bUndo', 'TooltipString','Undos last action and updates kymographs.');
                            
    tooltipstr='The code I use for tags.';        
    tagcodecallback=['msgbox(sprintf(''Tag4/7: 7: wiggly pause, 8: questionable point, 9: fitted wrong, 10: catastrophe, 11: reference point, 12:catastrophe after bumping, '...
        '15: rescue. \n Tag5/8: 0: As many filaments in bundle at tip as according to type. 1: One more. 15: One less. 14: Tip next to template tip.''));'];
    hDataGui.bTagCode = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback',tagcodecallback,...
                                'Position',[0.235 0.13 0.1 0.025],'String','Tag Code','Tag','bTagCode');
                            
%     
%    
%     hDataGui.bOnlyChecked = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''OnlyChecked'',getappdata(0,''hDataGui''));',...
%                              'Position',[0.235 0.510 0.1 0.025], 'String','Zoom selection','Tag','bOnlyChecked','UserData',0);    
                         
    tooltipstr='Zooms in on selection and only shows selected points in the table.';
                         
    hDataGui.bZoomIn = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''ZoomIn'',getappdata(0,''hDataGui''));',...
                             'Position',[0.235 0.510 0.1 0.025], 'String','Zoom selected','Tag','bZoomIn');   
                         
    tooltipstr='Select x values / frames in range.';                     
    hDataGui.bSelectX = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''SelectValues'',getappdata(0,''hDataGui''));',...
                             'Position',[0.025 0.48 0.1 0.025], 'String','Select X','Tag','bSelectX'); 
    tooltipstr='Select values of currently plotted y-values in range.';   
    hDataGui.bSelectY = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''SelectValues'',getappdata(0,''hDataGui''));',...
                             'Position',[0.025 0.51 0.1 0.025], 'String','Select Y','Tag','bSelectY'); 
                         
    tooltipstr='Select points tagged with this number (in the active tag column).';   
    hDataGui.bSelectTags = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''SelectValues'',getappdata(0,''hDataGui''));',...
                             'Position',[0.13 0.51 0.1 0.025], 'String','Select Tags','Tag','bSelectTags'); 
                         
    tooltipstr=sprintf('Selects PosStart, PosEnd, orientation and the order of Data{frame} such to be comparable to the previous frame of the object (does not make much sense for filaments with fast rotations compared to the frame rate).\n Allows negative orientations.');
    hDataGui.bFixOrientation = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''FixOrientation'',getappdata(0,''hDataGui''));',...
                                'Position',[0.56 0.48 0.1 0.025],'String','Fix orientation','Tag','bFixOrientation');
                            
    tooltipstr=sprintf('Interpolates results of the current track / deletes those interpolations. Interpolated points have "interpolated" set');
    hDataGui.bInterpolate = uicontrol('Parent',hDataGui.fig,'TooltipString', tooltipstr,'Units','normalized','Callback','fJKDataGui(''InterpolateTrack'',getappdata(0,''hDataGui''));',...
                                'Position',[0.665 0.48 0.1 0.025],'String','Interpolate','Tag','bInterpolate');
                              
                              %end JochenK
                              
    j = findjobj(hDataGui.fig,'class','label');
    set(j,'VerticalAlignment',1);
    set(hDataGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
    set(hDataGui.fig, 'WindowButtonUpFcn',@ButtonUp);
    set(hDataGui.fig, 'WindowButtonDownFcn',@ButtonDown);
    set(hDataGui.fig, 'KeyPressFcn',@KeyPress);
    set(hDataGui.fig, 'KeyReleaseFcn',@KeyRelease);
    set(hDataGui.fig, 'CloseRequestFcn',@Close);
    set(hDataGui.fig, 'WindowScrollWheelFcn',@Scroll);  
    set(hDataGui.tTable, 'CellEditCallback',@Select);
    set(hDataGui.tTable, 'CellSelectionCallback',@ReturnFocus);

    hDataGui.CursorDownPos = [0 0];
    hDataGui.Zoom = struct('currentXY',[],'globalXY',[],'level',[],'aspect',GetAxesAspectRatio(hDataGui.aPlot));
    hDataGui.SelectRegion = struct('X',[],'Y',[],'plot',[]);
    hDataGui.ZoomRegion = struct('X',[],'Y',[],'plot',[]);
    hDataGui.CursorMode='Normal';
    hDataGui.Colors=[1,0,1;0.896551724137931,1,0.793103448275862;1,0.586206896551724,0.793103448275862;1,0.965517241379310,0;0,0.413793103448276,0;0,0,0.620689655172414;1,1,1;0.379310344827586,0,0.344827586206897;0.517241379310345,0.413793103448276,0.275862068965517;0,1,0.655172413793103;0.689655172413793,0.482758620689655,1;1,0,0.413793103448276;0,0.448275862068966,0.413793103448276;0.448275862068966,0,0.103448275862069;1,0.758620689655172,0.379310344827586]; %JochenK

    setappdata(0,'hDataGui',hDataGui);
    setappdata(hDataGui.fig,'Object',Object);
    ShowTable(hDataGui);
    RefreshData(hDataGui,0,1);
else
    hDataGui.idx=idx;
    RefreshData(hDataGui,0,1);
end

function AlignColor(hDataGui)
global Molecule;
global Filament;
Object = getappdata(hDataGui.fig,'Object');
if Object.Channel~=1
    if Object.TformMat(1)~=1
        Type=hDataGui.Type;
        mode = ~get(hDataGui.cAligned, 'Value');
        if strcmp(Type,'Molecule')    
            Object = fTransformCoord(Object,mode,0);
            Molecule(hDataGui.idx)=Object;
        else
            Object = fTransformCoord(Object,mode,1);
            Filament(hDataGui.idx)=Object;
        end
        RefreshData(hDataGui,-1);
    else
        msgbox(['No OffsetMap applied to the object yet. Go press "Apply Offset Map" first'...
            '(this will unalign the other currently loaded Objects, so you will have to align them all again by clicking on "Align Channels."']);
        set(hDataGui.cAligned, 'Value', ~get(hDataGui.cAligned, 'Value'));
    end
else
        msgbox('No alignment needed for channel 1.');
        set(hDataGui.cAligned, 'Value', ~get(hDataGui.cAligned, 'Value'));
end

function ShowTable(hDataGui)
if get(hDataGui.cTable, 'Value')
    set(hDataGui.tTable,'Visible','on');
    set(hDataGui.pPlotPanel,'Position',[0.35 0.55 0.63 0.4]);
    set(hDataGui.pEdit,'Visible','off');
    set(hDataGui.pCustom,'Visible','off');
    set(hDataGui.cTable,'Position',[0.0025 0.2 0.02 0.025],'String','');
    set(hDataGui.bDeletePoints,'Position',[0.35 0.510 0.1 0.025]);            
    set(hDataGui.bSplit,'Position',[0.455 0.510 0.1 0.025]);
    set(hDataGui.bSwitch,'Position',[0.56 0.51 0.1 0.025]);
    set(hDataGui.tTags,'Position',[0.35 0.48 0.1 0.025]);  
    set(hDataGui.lTags,'Position',[0.455 0.48 0.1 0.025]);
    set(hDataGui.bFixOrientation,'Position',[0.56 0.48 0.1 0.025]);    
    set(hDataGui.bInsertPoints,'Position',[0.665 0.51 0.1 0.025]);
    set(hDataGui.bUndo,'Position',[0.77 0.510 0.1 0.025]);   
    set(hDataGui.bKymo,'Position',[0.875 0.51 0.075 0.025]);
    set(hDataGui.cKymo,'Position',[0.955 0.51 0.0175 0.025]);
    set(hDataGui.bInterpolate,'Position',[0.665 0.48 0.1 0.025]);
    set(hDataGui.bTagCode, 'Visible', 'off');
    RefreshData(hDataGui,-1);
else
    set(hDataGui.tTable,'Data',[]);
    set(hDataGui.tTable,'Visible','off');
    set(hDataGui.pPlotPanel,'Position',[0.35 0.025 0.63 0.925]);
    set(hDataGui.pEdit,'Visible','on');
    set(hDataGui.pCustom,'Visible','on');
    set(hDataGui.cTable,'Position',[0.025 0.2 0.1 0.025],'String','Show Table');
    set(hDataGui.bDeletePoints,'Position',[0.235 0.390 0.1 0.025]);            
    set(hDataGui.bSplit,'Position',[0.235 0.330 0.1 0.025]);
    set(hDataGui.bSwitch,'Position',[0.235 0.27 0.1 0.025]);
    set(hDataGui.tTags,'Position',[0.025 0.45 0.1 0.025]);  
    set(hDataGui.lTags,'Position',[0.13 0.45 0.1 0.025]);
    set(hDataGui.bFixOrientation,'Position',[0.235 0.24 0.1 0.025]);    
    set(hDataGui.bInsertPoints,'Position',[0.235 0.3 0.1 0.025]);
    set(hDataGui.bUndo,'Position',[0.235 0.36 0.1 0.025]);   
    set(hDataGui.bKymo,'Position',[0.235 0.45 0.075 0.025]);
    set(hDataGui.cKymo,'Position',[0.315 0.45 0.0175 0.025]);
    set(hDataGui.bInterpolate,'Position',[0.025 0.1 0.1 0.025]);
    set(hDataGui.bTagCode, 'Visible', 'on');
end

function SetComments
%the same as in fDataGui except for added
%fShared('BackUp',getappdata(0,'hMainGui')); and RefreshData(hDataGui,0);
%(because maybe the comment uses the comment functionality). The inactive
%comment string has been moved to RefreshData
global Filament;
global Molecule;
fShared('BackUp',getappdata(0,'hMainGui'));
hDataGui=getappdata(0,'hDataGui');
Object = getappdata(hDataGui.fig,'Object');
Object.Comments = get(hDataGui.eComments,'String');
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
RefreshData(hDataGui,0);

function SetChannel
%the same as in fDataGui except for added fShared('BackUp',getappdata(0,'hMainGui'));
global Filament;
global Molecule;
fShared('BackUp',getappdata(0,'hMainGui'));
hDataGui=getappdata(0,'hDataGui');
Object = getappdata(hDataGui.fig,'Object');
if Object.Drift==1
    answer = questdlg({'This track has been drift corrected, therefore',' changing in channel might yield corrupt results.','','You probably should undo drift correction first! Want to continue anyway?'},'warn');
    if isempty(answer)
        set(hDataGui.eChannel,'String',num2str(Object.Channel));
        return
    else
        if strcmp(answer, 'No')
                set(hDataGui.eChannel,'String',num2str(Object.Channel));
                return
        end
    end
end
hMainGui=getappdata(0,'hMainGui');
set(hMainGui.Menu.mAlignChannels,'Checked','off');
Molecule = fTransformCoord(Molecule,1,0);
Filament = fTransformCoord(Filament,1,1);
if strcmp(hDataGui.Type,'Molecule')==1
    Object = fTransformCoord(Object,1,0);
else
    Object = fTransformCoord(Object,1,1);
end
fShared('UpdateMenu',hMainGui);   
Object.Channel = str2double(get(hDataGui.eChannel,'String'));
if isnan(Object.Channel) 
    Object.Channel = 1;
end
setappdata(hDataGui.fig,'Object',Object)
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
fShow('Image');
fShow('Tracks');


function Kymo
hDataGui=getappdata(0,'hDataGui');
Tags = getappdata(hDataGui.fig,'Tags');
Object = getappdata(hDataGui.fig,'Object');
if strcmp(hDataGui.Type,'Molecule')==1
    Results = Object.Results(Tags(:,5)~=9);
    x = sort(Results(:,3));
    y = sort(Results(:,4));
    coords=double([[x(1) y(1)]; [x(end) y(end)]]./Object.PixelSize);
    addsign=1;
else
    ignore = Tags(:,5)==9 | (Tags(:,6)==9)  | (Tags(:,9)==9);
    PosStart = Object.PosStart(~ignore,:);
    PosEnd = Object.PosEnd(~ignore,:);
    xfull = sortrows([[PosStart(:,1); PosEnd(:,1)] [PosStart(:,2); PosEnd(:,2)]],1);
    yfull = sortrows([[PosStart(:,2); PosEnd(:,2)] [PosStart(:,1); PosEnd(:,1)]],1);
    x = [median(xfull(1:10,:)); median(xfull(end-9:end,:))];
    y = [median(yfull(1:10,:)); median(yfull(end-9:end,:))];
    if abs(y(1,1)-x(1,2))>abs(y(end,1)-x(1,2))
        coords=double([[x(end,1) y(1,1)]; [x(1,1) y(end,1)]]./Object.PixelSize);
        addsign=-1;
    else
        coords=double([[x(1,1) y(1,1)]; [x(end,1) y(end,1)]]./Object.PixelSize);
        addsign=1;
    end
end
delta = coords(1,:) - coords(2,:);
m=addsign*double(delta(2)/delta(1));
addx=sqrt(25/(1+m^2));
hMainGui=getappdata(0,'hMainGui');
hMainGui.Scan = struct('X',[0 0],'Y',[0 0]);
hMainGui.Scan.X = [coords(1,1)-addsign*addx coords(2,1)+addsign*addx];
hMainGui.Scan.Y = [coords(1,2)-addx*m coords(2,2)+addx*m];
hMainGui.KymoName = Object.Name;
fRightPanel('NewScan',hMainGui);
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
if get(hDataGui.cKymo,'Value')
    set(hMainGui.RightPanel.pTools.eKymoStart,'String', num2str(max(1, round(Object.Results(1,1))-5)));
    set(hMainGui.RightPanel.pTools.eKymoEnd,'String', num2str(min(N, round(Object.Results(end,1))+5)));
end
fRightPanel('ShowKymoGraph',getappdata(0,'hMainGui'));

function Clear(h,~)
set(h,'String','','Enable','on','ForegroundColor','k','HorizontalAlignment','left','ButtonDownFcn','')
uicontrol(h);

function CreateTable(hDataGui,check, data, tags)
flags = num2cell(logical(tags(:,1:4)));
if hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==2
    tags = num2cell(tags(:,5));
elseif hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==3
    tags = num2cell(tags(:,[5 9 10 11]));
else
    tags = num2cell(tags(:,5:8));
end
set(hDataGui.tTable,'Units','pixels');
Pos = get(hDataGui.tTable,'Position');
set(hDataGui.tTable,'Units','normalized');
if hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==2
    columnname = {'Select','Row Num', 'Frame','Time[sec]','Distance[nm]','Missed','Interpolated','Tag1','Tag2','Tag3'};
    columnweight = [ 1, 1.1, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 1];
elseif hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==3
    columnname = {'Select','Row Num', 'Frame','Time[sec]','Distance[nm]','Missed','Interpolated','Tag1','Tag2','Tag3','Tag7','Tag8','Tag9'};
    columnweight = [ 1, 1.1, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 1, 1, 1, 1];
else
    columnname = {'Select','Row Num', 'Frame','Time[sec]','Distance[nm]','Missed','Interpolated','Tag1','Tag2','Tag3','Tag4','Tag5','Tag6'};
    columnweight = [ 1, 1.1, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 1, 1, 1, 1];
end
columnformat={'logical','numeric','numeric','numeric','numeric','logical','logical','logical','logical','numeric','numeric','numeric','numeric'};
columnwidth = fix(columnweight*Pos(3)*0.98/sum(columnweight));
columneditable = logical([1 0 0 0 0 0 0 0 0 0 0]);
if size(data, 2) < 4
    data = [num2cell(1:size(check,1))' data];
end
set(hDataGui.tTable,'Data',[check data flags tags],'ColumnName',columnname,'ColumnFormat',columnformat,'ColumnWidth',num2cell(columnwidth), 'ColumnEditable', columneditable);

function selcbk(hObject,eventdata) %#ok<INUSD>
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
hDataGui=getappdata(0,'hDataGui');
hMainGui=getappdata(0,'hMainGui');
color=get(get(hDataGui.gColor,'SelectedObject'),'UserData');
Object=getappdata(hDataGui.fig,'Object');
Object.Color=color;
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')
    Molecule(hDataGui.idx)=Object;
    try
        set(Molecule(hDataGui.idx).PlotHandles(1),'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Molecule(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackMol.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackMol(k).PlotHandles(1),'Color',color);   
        end
    catch
    end
else
    Filament(hDataGui.idx)=Object;
    try
        set(Filament(hDataGui.idx).PlotHandles(1),'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Microtuble(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackFil.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackFil(k).PlotHandles(1),'Color',color);            
        end
    catch
    end
end
ReturnFocus([],[]);

function Navigation(n)
hDataGui=getappdata(0,'hDataGui');
Create(hDataGui.Type,hDataGui.idx+n);

function DeleteObject(hDataGui)
global Molecule;
global Filament;
fShared('BackUp',getappdata(0,'hMainGui'));
MolSelect = zeros(size([Molecule.Selected]));
FilSelect = zeros(size([Filament.Selected]));
n=0;
if strcmp(hDataGui.Type,'Molecule')
    MolSelect(hDataGui.idx)=1; 
    if length(MolSelect)==hDataGui.idx
        n=-1;
    end
else
    FilSelect(hDataGui.idx)=1; 
    if length(FilSelect)==hDataGui.idx
        n=-1;
    end
end
fShared('DeleteTracks',getappdata(0,'hMainGui'),MolSelect,FilSelect);
if hDataGui.idx==1 && n==-1
    close(hDataGui.fig);
else
    Create(hDataGui.Type,hDataGui.idx+n);
end

function Undo(hDataGui)
hMainGui=getappdata(0,'hMainGui');
fMenuEdit('Undo',hMainGui);
RefreshData(hDataGui,0, 1);

function ApplyTags(hDataGui)
%the same as in fDataGui except for added fShared('BackUp',getappdata(0,'hMainGui'));
%and it doesnt deselect anymore
global Molecule;
global Filament;
Tags = getappdata(hDataGui.fig,'Tags');
activeTag = get(hDataGui.lTags, 'Value');
v = get(hDataGui.lTagNumber,'Value')-1;
if activeTag<3
    warndlg('"Missed" is reserved for "Fit missing frames" and "Interpolated" for "Interpolate".');
    return
end
if activeTag<5&&v>1
    warndlg('You have selected a binary tag as active. Only 0 or 1 are allowed values.');
    return
end
if hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==2 && activeTag>5
    msgbox('You have selected the center position as reference for a tag field assigned to either the start or the end position.');
    return
elseif hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==3
    if activeTag>5
        activeTag=activeTag+3;
    end
end
fShared('BackUp',getappdata(0,'hMainGui'));
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
idx = Check==1;
Tags(idx, activeTag)=v;
setappdata(hDataGui.fig,'Tags', Tags);
Object.Results(idx,end) = fJKtags2float(Tags(idx,:));
Check(:) = 0;
setappdata(hDataGui.fig,'Check',Check);
if get(hDataGui.cTable, 'Value')
    CreateTable(hDataGui,num2cell(Check), num2cell(Object.Results(:,[1,2,6])), Tags);
end
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
if v == 11
    RefreshData(hDataGui,-1);
else
    Draw(hDataGui,-1);
end


function FlipTags(hDataGui)
%the same as in fDataGui except for added fShared('BackUp',getappdata(0,'hMainGui'));
%and it doesnt deselect anymore
global Molecule;
global Filament;
Tags = getappdata(hDataGui.fig,'Tags');
activeTag = get(gcbo, 'UserData');
fShared('BackUp',getappdata(0,'hMainGui'));
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
idx = Check==1;
Tags(idx, activeTag)=~Tags(idx, activeTag);
setappdata(hDataGui.fig,'Tags', Tags);
Object.Results(idx,end) = fJKtags2float(Tags(idx,:));
Check(:) = 0;
setappdata(hDataGui.fig,'Check',Check);
if get(hDataGui.cTable, 'Value')
    CreateTable(hDataGui,num2cell(Check), num2cell(Object.Results(:,[1,2,6])), Tags);
end
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')==1
    Molecule(hDataGui.idx)=Object;
else
    Filament(hDataGui.idx)=Object;
end
Draw(hDataGui,-1);

function Export(hDataGui)
fExportDataGui('Create',hDataGui.Type,hDataGui.idx);
ReturnFocus([],[]);

function Draw(hDataGui,ax)
%the same as in fDataGui
%get object data
Object=getappdata(hDataGui.fig,'Object');
%save current view
if ishandle(hDataGui.aPlot)&&ax==-1
    xy=get(hDataGui.aPlot,{'xlim','ylim'});
else
    xy={[0 1] [0 1]};
end

%get plot colums
x=get(hDataGui.lXaxis,'Value');
XList=get(hDataGui.lXaxis,'UserData');
XPlot=XList.data{x};

y=get(hDataGui.lYaxis,'Value');
YList=get(hDataGui.lYaxis,'UserData');
if ~isempty(XPlot)
    YPlot{1}=YList(x).data{y};
else
    XPlot=YList(x).data{y}(:,1);
    YPlot{1}=YList(x).data{y}(:,2);
    XList.list{x}=YList(x).list{y};
    XList.units{x}=YList(x).units{y};
    YList(x).list{y}='number of data points';    
    YList(x).units{y}='';
end
                  
cla(hDataGui.aPlot,'reset');
%hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'TickDir','out',...
   %                   'XLimMode','manual','YLimMode','manual'); 
hDataGui.DataPlot = [];                  
set(0,'CurrentFigure',hDataGui.fig);                  
setappdata(0,'hDataGui',hDataGui);                 
hold on     
xscale=1;
yscale=1;
if strcmp(XList.units{x},'[nm]') && (max(XPlot)-min(XPlot))>5000
    xscale=1000;
    XList.units{x}=['[' char(956) 'm]'];
    if strcmp(YList(x).units{y},'[nm]')
        yscale=1000;
        YList(x).units{y}=['[' char(956) 'm]'];
    end
end
if strcmp(YList(x).units{y},'[nm]') && (max(YPlot{1})-min(YPlot{1}))>5000
    yscale=1000;
    YList(x).units{y}=['[' char(956) 'm]'];
    if strcmp(XList.units{x},'[nm]')
        xscale=1000;
        XList.units{x}=['[' char(956) 'm]']; 
    end
end
if x<length(XList.data)
    FilXY = [];
    if x==1
        Dis=norm([Object.Results(1,3)-Object.Results(end,3) Object.Results(1,4)-Object.Results(end,4)]);     
        if strcmp(hDataGui.Type,'Filament')
            FilXY=cell(1,4);
            lData=length(Object.Data);
            VecX=zeros(lData,2);
            VecY=zeros(lData,2);
            VecU=zeros(lData,2);
            VecV=zeros(lData,2);
            Length=mean(Object.Results(:,7)); 
            for i=1:lData
                n=size(Object.Data{i},1);     
                if n>1
                    line((Object.Data{i}(:,1)-min(XPlot))/xscale,(Object.Data{i}(:,2)-min(YPlot{1}))/yscale,'Color','red','LineStyle','-','Marker','none');
                    if Dis<=2*Object.PixelSize
                        VecX(i,:)=[Object.Data{i}(ceil(n/4),1) Object.Data{i}(fix(3*n/4),1)]-min(XPlot);
                        VecY(i,:)=[Object.Data{i}(ceil(n/4),2) Object.Data{i}(fix(3*n/4),2)]-min(YPlot{1});                    
                        VecU(i,:)=[Object.Data{i}(ceil(n/4)+1,1) Object.Data{i}(fix(3*n/4)+1,1)]-min(XPlot);
                        VecV(i,:)=[Object.Data{i}(ceil(n/4)+1,2) Object.Data{i}(fix(3*n/4)+1,2)]-min(YPlot{1});
                    end
                    FilXY{1} = min([(Object.Data{i}(:,1)'-min(XPlot)) FilXY{1}]);
                    FilXY{2} = max([(Object.Data{i}(:,1)'-min(XPlot)) FilXY{2}]);                    
                    FilXY{3} = min([(Object.Data{i}(:,2)'-min(YPlot{1})) FilXY{3}]);
                    FilXY{4} = max([(Object.Data{i}(:,2)'-min(YPlot{1})) FilXY{4}]);                    
                end
            end
            if Dis<=2*Object.PixelSize
                VecX=mean(VecX);
                VecY=mean(VecY);                
                VecU=mean(VecU);
                VecV=mean(VecV);                            
                U=(VecU-VecX)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);
                V=(VecV-VecY)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);                
                fill([VecX(1)+Length/20*U(1) VecX(1)+Length/40*V(1) VecX(1)-Length/40*V(1)]/xscale,[VecY(1)+Length/20*V(1) VecY(1)-Length/40*U(1) VecY(1)+Length/40*U(1)]/yscale,'r','EdgeColor','none');
                if lData>1
                    fill([VecX(2)+Length/20*U(2) VecX(2)+Length/40*V(2) VecX(2)-Length/40*V(2)]/xscale,[VecY(2)+Length/20*V(2) VecY(2)-Length/40*U(2) VecY(2)+Length/40*U(2)]/yscale,'r','EdgeColor','none');                
                end
            end
        end
        if Dis>2*Object.PixelSize     
            n(1) = find(Object.Results(:,6)<Dis/4,1,'last');
            n(2) = find(Object.Results(:,6)<Dis/2,1,'last');
            n(3) = find(Object.Results(:,6)<3*Dis/4,1,'last');
            n(4) = size(Object.Results,1);     
            VecX=[Object.Results(n(1),3) Object.Results(n(2),3) Object.Results(n(3),3)]-min(XPlot);
            VecY=[Object.Results(n(1),4) Object.Results(n(2),4) Object.Results(n(3),4)]-min(YPlot{1});                    
            VecU=[mean(Object.Results(n(1)+1:n(2),3)) mean(Object.Results(n(2)+1:n(3),3)) mean(Object.Results(n(3)+1:n(4),3))]-min(XPlot);
            VecV=[mean(Object.Results(n(1)+1:n(2),4)) mean(Object.Results(n(2)+1:n(3),4)) mean(Object.Results(n(3)+1:n(4),4))]-min(YPlot{1});
            U=(VecU-VecX)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);
            V=(VecV-VecY)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);    
            for m = 1:3
                fill([VecX(m)+Dis/15*U(m) VecX(m)+Dis/30*V(m) VecX(m)-Dis/30*V(m)]/xscale,[VecY(m)+Dis/15*V(m) VecY(m)-Dis/30*U(m) VecY(m)+Dis/30*U(m)]/yscale,[0.8 0.8 0.8],'EdgeColor','none');
            end   
        end
        
        XPlot=XPlot-min(XPlot);
        YPlot{1}=YPlot{1}-min(YPlot{1});        
    end

    %get checked table entries
    Check = getappdata(hDataGui.fig,'Check');
    k=find(Check==1);

    if strcmp(get(hDataGui.cYaxis2,'Enable'),'on') && get(hDataGui.cYaxis2,'Value')

        y2=get(hDataGui.lYaxis2,'Value');
        YList2=get(hDataGui.lYaxis2,'UserData');    
        YPlot{2}=YList2(x).data{y2};
        yscale(2) = 1;
        if strcmp(YList2(x).units{y2},'[nm]') && max(YPlot{2})-min(YPlot{2})>5000
            yscale(2)=1000;
            YList2(x).units{y2}=['[' char(956) 'm]'];
        end
    else 
        YList2 = [];
        y2=[];
    end
    for n = 1:numel(YPlot)
        if numel(YPlot)>1
            if n==1
                astr = 'left';
                c = [0 0.4470 0.7410];
            else
                astr = 'right';
                c = [0.8500 0.3250 0.0980];
            end
            yyaxis(hDataGui.aPlot,astr);
        else
            astr = [];
            c = [0 0.4470 0.7410];
        end
        hDataGui.DataPlot(n) = line(XPlot/xscale,YPlot{n}/yscale(n),'Color',c);
        if k>0
            line(XPlot(k)/xscale,YPlot{n}(k)/yscale(n),'Color','green','LineStyle','none','Marker','o');
        end
        set(hDataGui.aPlot,'TickDir','out','YTickMode','auto');
        SetLabels(hDataGui,XList,YList,YList2,x,y,y2);
        if n==numel(YPlot)
            tags = getappdata(hDataGui.fig,'Tags');
            colorby = get(hDataGui.lTags, 'Value');
            if hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==3
                tags = tags(:,[1 2 3 4 5 9 10 11]);
            else
                tags = tags(:,[1 2 3 4 5 6 7 8]);
            end
            hastags=logical(tags(:,colorby));
            if size(hastags,1) == length(XPlot)
                if any(hastags) && ~(hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==2 && colorby>5)
        %             line(XPlot(tags(:,1))/xscale,YPlot{n}(tags(:,1))/yscale(n),'Color','blue','LineStyle','none','Marker','+','MarkerSize',4);  
                    taggedrows=tags(hastags,:);
                    if colorby>4
                        c = hDataGui.Colors;
                    else
                        c = [1 0 1];
                    end
                    XTagPlot=XPlot(hastags)/xscale;
                    YTagPlot=YPlot{1}(hastags)/yscale(1);
                    if n==1
                        scatter(XTagPlot, YTagPlot, 20, c(taggedrows(:,colorby),:), 'd', 'fill');
                    else
                        yyaxis left
                        scatter(XTagPlot, YTagPlot, 20, c(taggedrows(:,colorby),:), 'd', 'fill');
                        yyaxis right
                        YTagPlot=YPlot{2}(hastags)/yscale(2);
                        scatter(XTagPlot, YTagPlot, 20, c(taggedrows(:,colorby),:), 'd', 'fill');
                    end
                end
            end
        end
        if gcbo == hDataGui.bZoomIn
            xy = {[min(XPlot(k))/xscale max(XPlot(k))/xscale] [min(YPlot{1}(k))/yscale(1) max(YPlot{1}(k))/yscale(1)]};
        end
        if ~isempty(FilXY)
            XPlot=[FilXY{1} FilXY{2}];
            YPlot{n}=[FilXY{3} FilXY{4}];
        end   
        if length(XPlot)>1
            SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot{n}/yscale(n),x,astr);
        else
            axis auto;
        end
        set(hDataGui.DataPlot(n),'Marker','.','MarkerSize',15);
    end
else
    hDataGui.DataPlot=bar(hDataGui.aPlot,XPlot/xscale,YPlot{1}/yscale(1),'BarWidth',1,'EdgeColor','black','FaceColor','blue','LineWidth',1);
    SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot{1}/yscale(1),NaN,[]); 
    SetLabels(hDataGui,XList,YList,[],x,y,[]);
end
hold off;
if gcbo == hDataGui.bZoomIn
    x_total=hDataGui.Zoom.globalXY{1}(2)-hDataGui.Zoom.globalXY{1}(1);
    y_total=hDataGui.Zoom.globalXY{2}(2)-hDataGui.Zoom.globalXY{2}(1);  
    x_current=xy{1}(2)-xy{1}(1);
    y_current=xy{2}(2)-xy{2}(1);   
    hDataGui.Zoom.level = -log((x_current/x_total +  y_current/y_total)/2)*8;
    hDataGui.Zoom.currentXY = xy;
    set(hDataGui.aPlot,{'xlim','ylim'},xy);
else
    if xy{1}(2)~=1&&xy{2}(2)~=1 && ax==-1
        set(hDataGui.aPlot,{'xlim','ylim'},xy);
    else
        hDataGui.Zoom.globalXY = get(hDataGui.aPlot,{'xlim','ylim'});
        hDataGui.Zoom.currentXY = hDataGui.Zoom.globalXY;
        hDataGui.Zoom.level = 0;
    end
end
setappdata(0,'hDataGui',hDataGui);
ReturnFocus([],[]);

function SetAxis(a,X,Y,idx,mode)
if ~isempty(mode)
   yyaxis(a,mode); 
end
set(a,'Units','pixel');
pos=get(a,'Position');
set(a,'Units','normalized');
if idx==1
    xy{1}=[-ceil(max(-X)) ceil(max(X))]+[-0.01 0.01]*(max(X)-min(X));
    xy{2}=[-ceil(max(-Y)) ceil(max(Y))]+[-0.01 0.01]*(max(Y)-min(Y));
else
    xy{1}=[min(X) max(X)];
    xy{2}=[min(Y) max(Y)];
end
if all(~isnan(xy{1}))&&all(~isnan(xy{2}))
    if idx==1
        lx=max(X)-min(X);
        ly=max(Y)-min(Y);
        if ly>lx
            xy{1}(2)=min(X)+lx/2+ly/2;
            xy{1}(1)=min(X)+lx/2-ly/2;
        else
            xy{2}(2)=min(Y)+ly/2+lx/2;            
            xy{2}(1)=min(Y)+ly/2-lx/2;
        end
        lx=xy{1}(2)-xy{1}(1);
        xy{1}(1)=xy{1}(1)-lx*(pos(3)/pos(4)-1)/2;
        xy{1}(2)=xy{1}(2)+lx*(pos(3)/pos(4)-1)/2;
        set(a,{'xlim','ylim'},xy,'YDir','reverse');
    else
        if xy{1}(1)>=xy{1}(2) || xy{2}(1)>=xy{2}(2)
            xy = {[0 1] [0 1]};
        end
        set(a,{'xlim','ylim'},xy,'YDir','normal');
        if isnan(idx)
            XTick=get(a,'XTick');
            s=length(XTick);
            xy{1}(1)=2*XTick(1)-XTick(2); 
            xy{1}(2)=2*XTick(s)-XTick(s-1); 
            xy{2}(1)=0;
        end
        YTick=get(a,'YTick');
        s=length(YTick);
        if YTick(1)~=0
            xy{2}(1)=2*YTick(1)-YTick(2); 
        end            
        xy{2}(2)=2*YTick(s)-YTick(s-1); 
        set(a,{'xlim','ylim'},xy,'YDir','normal');
    end
end


function SetLabels(hDataGui,XList,YList,YList2,x,y,y2)
if ~isempty(y2)
    yyaxis(hDataGui.aPlot,'left');
end
xlabel([XList(1).list{x} '  ' XList.units{x}]);
ylabel([YList(x).list{y} '  ' YList(x).units{y}]);
if ~isempty(y2)
    yyaxis(hDataGui.aPlot,'right');
    ylabel([YList2(x).list{y2} '  ' YList2(x).units{y2}]);
end

function KeyPress(~,evnt)
hDataGui=getappdata(0,'hDataGui');
if strcmp(hDataGui.CursorMode,'Normal');
    switch(evnt.Key)
        case 'shift' 
            hDataGui.CursorMode='Zoom';
            CData = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,1,1,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,1,1,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2;];
            set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[6 6]);
            hDataGui.CursorDownPos(:)=0;        
            if ~isempty(hDataGui.SelectRegion.plot)
                delete(hDataGui.SelectRegion.plot);    
                hDataGui.SelectRegion.plot=[];
            end
        otherwise
            hDataGui.CursorMode='Normal';
            set(hDataGui.fig,'pointer','arrow');
    end
    setappdata(0,'hDataGui',hDataGui);
end

function KeyRelease(~, evnt) 
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if strcmp(hDataGui.CursorMode,'Zoom');
    if strcmp(evnt.Key,'shift')
        if all(hDataGui.CursorDownPos~=0) && all(hDataGui.CursorDownPos~=cp) 
            xy{1} =  [min(hDataGui.ZoomRegion.X) max(hDataGui.ZoomRegion.X)];
            xy{2} =  [min(hDataGui.ZoomRegion.Y) max(hDataGui.ZoomRegion.Y)];
            set(hDataGui.aPlot,{'xlim','ylim'},xy);
            hDataGui.Zoom.currentXY = xy;
            x_total=hDataGui.Zoom.globalXY{1}(2)-hDataGui.Zoom.globalXY{1}(1);
            y_total=hDataGui.Zoom.globalXY{2}(2)-hDataGui.Zoom.globalXY{2}(1);    
            x_current=hDataGui.Zoom.currentXY{1}(2)-hDataGui.Zoom.currentXY{1}(1);
            y_current=hDataGui.Zoom.currentXY{2}(2)-hDataGui.Zoom.currentXY{2}(1);   
            hDataGui.Zoom.level = -log((x_current/x_total +  y_current/y_total)/2)*8;
        end
        if ~isempty(hDataGui.ZoomRegion.plot)
            delete(hDataGui.ZoomRegion.plot);    
            hDataGui.ZoomRegion.plot=[];
        end
        hDataGui.CursorDownPos(:)=0;     
        hDataGui.CursorMode='Normal';
        setappdata(0,'hDataGui',hDataGui);
        set(hDataGui.fig,'pointer','arrow');
    end
end
 
function ButtonDown(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
pos = get(hDataGui.pPlotPanel,'Position');
cpFig = get(hDataGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)]) 
    if strcmp(get(hDataGui.fig,'SelectionType'),'normal')
        hDataGui.CursorMode='Normal';
        if all(hDataGui.CursorDownPos==0)
            hDataGui.SelectRegion.X=cp(1);
            hDataGui.SelectRegion.Y=cp(2);
            hDataGui.SelectRegion.plot=line(cp(1),cp(2),'Color','black','LineStyle',':','Tag','pSelectRegion');                   
            hDataGui.CursorDownPos=cp;                   
        end
    elseif strcmp(get(hDataGui.fig,'SelectionType'),'extend')
        if strcmp(hDataGui.CursorMode,'Normal');
            hDataGui.CursorMode='Pan';
            hDataGui.CursorDownPos=cp;  
            CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
            CData(CData==1)=2;
            set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);
        elseif strcmp(hDataGui.CursorMode,'Zoom');
            if all(hDataGui.CursorDownPos==0)
                hDataGui.ZoomRegion.X=cp(1);
                hDataGui.ZoomRegion.Y=cp(2);
                hDataGui.ZoomRegion.plot=line(cp(1),cp(2),'Color','black','LineStyle','--','Tag','pZoomRegion');                   
                hDataGui.CursorDownPos=cp;                   
            end
        end
    end
    setappdata(0,'hDataGui',hDataGui);
end


function ButtonUp(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
if ishandle(hDataGui.DataPlot)
    set(0,'CurrentFigure',hDataGui.fig);
    set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
    Check=getappdata(hDataGui.fig,'Check');
    xy=get(hDataGui.aPlot,{'xlim','ylim'});
    cp=get(hDataGui.aPlot,'currentpoint');
    cp=cp(1,[1 2]);
    X=get(hDataGui.DataPlot,'XData');
    Y=get(hDataGui.DataPlot,'YData');
    if iscell(X)
        X = X{1};
        Y = Y{1};
        refresh = 0;
    else
        refresh = -1;
    end
    if strcmp(hDataGui.CursorMode,'Normal')    
        k = [];
        if all(hDataGui.CursorDownPos==cp)
            dx=((xy{1}(2)-xy{1}(1))/40);
            dy=((xy{2}(2)-xy{2}(1))/40);
            k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
            [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
            Check(k(t)) = ~Check(k(t));
        elseif all(hDataGui.CursorDownPos~=0)
            hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)];
            hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)];
            IN = inpolygon(X,Y,hDataGui.SelectRegion.X,hDataGui.SelectRegion.Y);
            Check(IN) = ~Check(IN);
            k=find(IN==1);
        end
        hDataGui.CursorDownPos(:)=0;        
        if ~isempty(hDataGui.SelectRegion.plot)
            delete(hDataGui.SelectRegion.plot);    
            hDataGui.SelectRegion.plot=[];
        end
        if ~isempty(k)
            data = get(hDataGui.tTable,'Data');
            if length(Check)==size(data,1)
                data(:,1) = num2cell(Check);
                set(hDataGui.tTable,'Data',data);
            end
        end
    elseif strcmp(hDataGui.CursorMode,'Pan')    
        hDataGui.CursorDownPos(:)=0;    
        hDataGui.CursorMode='Normal';
        set(hDataGui.fig,'pointer','arrow');
    elseif strcmp(hDataGui.CursorMode,'Zoom')  
        if all(hDataGui.CursorDownPos~=0) && all(hDataGui.CursorDownPos~=cp) 
            xy{1} =  [min(hDataGui.ZoomRegion.X) max(hDataGui.ZoomRegion.X)];
            xy{2} =  [min(hDataGui.ZoomRegion.Y) max(hDataGui.ZoomRegion.Y)];
            set(hDataGui.aPlot,{'xlim','ylim'},xy);
            hDataGui.Zoom.currentXY = xy;
            x_total=hDataGui.Zoom.globalXY{1}(2)-hDataGui.Zoom.globalXY{1}(1);
            y_total=hDataGui.Zoom.globalXY{2}(2)-hDataGui.Zoom.globalXY{2}(1);    
            x_current=hDataGui.Zoom.currentXY{1}(2)-hDataGui.Zoom.currentXY{1}(1);
            y_current=hDataGui.Zoom.currentXY{2}(2)-hDataGui.Zoom.currentXY{2}(1);   
            hDataGui.Zoom.level = -log((x_current/x_total +  y_current/y_total)/2)*8;
        else
            if strcmp(get(hDataGui.fig,'SelectionType'),'extend') || strcmp(get(hDataGui.fig,'SelectionType'),'open')
                hDataGui.Zoom.level = hDataGui.Zoom.level + 1;
            else
                hDataGui.Zoom.level = hDataGui.Zoom.level - 1 ;
            end
            setappdata(0,'hDataGui',hDataGui);
            Scroll([],[]);
            hDataGui = getappdata(0,'hDataGui');
        end
        if ~isempty(hDataGui.ZoomRegion.plot)
            delete(hDataGui.ZoomRegion.plot);    
            hDataGui.ZoomRegion.plot=[];
        end
        hDataGui.CursorDownPos(:)=0;    
    end
    setappdata(hDataGui.fig,'Check',Check);
    setappdata(0,'hDataGui',hDataGui);
    Draw(hDataGui,refresh);
end


function UpdateCursor(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
try
    if ishandle(hDataGui.DataPlot)
        set(0,'CurrentFigure',hDataGui.fig);
        set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
        Object=getappdata(hDataGui.fig,'Object');
        pos = get(hDataGui.pPlotPanel,'Position');
        cpFig = get(hDataGui.fig,'currentpoint');
        cpFig = cpFig(1,[1 2]);
        xy=get(hDataGui.aPlot,{'xlim','ylim'});
        cp=get(hDataGui.aPlot,'currentpoint');
        cp=cp(1,[1 2]);
        X=get(hDataGui.DataPlot,'XData');
        Y=get(hDataGui.DataPlot,'YData');
        if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
            if strcmp(hDataGui.CursorMode,'Normal')
                dx=((xy{1}(2)-xy{1}(1))/40);
                dy=((xy{2}(2)-xy{2}(1))/40);
                k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
                [~,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
                set(hDataGui.tFrameValue,'String',num2str(Object.Results(k(t),1)));
                if all(hDataGui.CursorDownPos~=0)
                    hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X cp(1)];
                    hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y cp(2)];
                    if ~isempty(hDataGui.SelectRegion.plot)
                        delete(hDataGui.SelectRegion.plot);    
                        hDataGui.SelectRegion.plot=[];
                    end
                    hDataGui.SelectRegion.plot = line([hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)] ,[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)],'Color','black','LineStyle',':','Tag','pSelectRegion');
                end
                set(hDataGui.fig,'pointer','arrow');
            elseif strcmp(hDataGui.CursorMode,'Pan')
                if all(hDataGui.CursorDownPos~=0)
                    Zoom=hDataGui.Zoom;
                    xy=Zoom.currentXY;
                    xy{1}=xy{1}-(cp(1)-hDataGui.CursorDownPos(1));
                    xy{2}=xy{2}-(cp(2)-hDataGui.CursorDownPos(2));
                    if xy{1}(1)<Zoom.globalXY{1}(1)
                        xy{1}=xy{1}-xy{1}(1)+Zoom.globalXY{1}(1);
                    end
                    if xy{1}(2)>Zoom.globalXY{1}(2)
                        xy{1}=xy{1}-xy{1}(2)+Zoom.globalXY{1}(2);
                    end
                    if xy{2}(1)<Zoom.globalXY{2}(1)
                        xy{2}=xy{2}-xy{2}(1)+Zoom.globalXY{2}(1);
                    end
                    if xy{2}(2)>Zoom.globalXY{2}(2)
                        xy{2}=xy{2}-xy{2}(2)+Zoom.globalXY{2}(2);
                    end
                    set(hDataGui.aPlot,{'xlim','ylim'},xy);
                    hDataGui.Zoom.currentXY=xy;
                end
                CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,NaN,1,1,NaN,1,1,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,2,2,1,2,2,1,2,2,1,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,1,2,1,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,NaN,1,1,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,2,1,NaN;NaN,NaN,1,2,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,1,2,2,2,2,2,2,2,2,2,1,NaN,NaN;NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN;];
                set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[10 9]);    
            elseif strcmp(hDataGui.CursorMode,'Zoom')
                if all(hDataGui.CursorDownPos~=0)
                    hDataGui.ZoomRegion.X=[hDataGui.ZoomRegion.X(1) hDataGui.ZoomRegion.X(1) cp(1) cp(1) hDataGui.ZoomRegion.X(1)];
                    hDataGui.ZoomRegion.Y=[hDataGui.ZoomRegion.Y(1) cp(2) cp(2) hDataGui.ZoomRegion.Y(1) hDataGui.ZoomRegion.Y(1)];
                    if ~isempty(hDataGui.ZoomRegion.plot)
                        delete(hDataGui.ZoomRegion.plot);    
                        hDataGui.ZoomRegion.plot=[];
                    end
                    hDataGui.ZoomRegion.plot = line(hDataGui.ZoomRegion.X ,hDataGui.ZoomRegion.Y,'Color','black','LineStyle','--','Tag','pZoomRegion');
                end
                CData = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,1,1,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,1,1,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2;];
                set(hDataGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[6 6]);
            end
            setappdata(0,'hDataGui',hDataGui);
        else 
            set(hDataGui.tFrameValue,'String','');
            set(hDataGui.fig,'pointer','arrow');
        end
    end
catch
    warning('UpdateCursor problem');
end

function Close(hObject,eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
hDataGui.idx=0;
hDataGui.Extensions.JochenK.CopyNumber = []; %JochenK
setappdata(0,'hDataGui',hDataGui);
set(hDataGui.fig,'Visible','off','WindowStyle','normal');
fShared('ReturnFocus');
%fShow('Tracks');


function DeletePoints(hDataGui)
global Filament;
global Molecule;
if hDataGui.BackUp==1
    fShared('BackUp',getappdata(0,'hMainGui'));
else
    hDataGui.BackUp=1;
end
Object = getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
Tags = getappdata(hDataGui.fig,'Tags');
if sum(Check)<size(Object.Results,1)
    Tags(Check==1,:)=[];
    Object.Results(Check==1,:)=[];
    if strcmp(hDataGui.Type,'Filament')==1
        Object.PosStart(Check==1,:)=[];
        Object.PosCenter(Check==1,:)=[];   
        Object.PosEnd(Check==1,:)=[];
        Object.Data(Check==1)=[];    
    end
    if ~isempty(Object.PathData)
        Object.PathData(Check==1,:)=[];   
    end
    if strcmp(hDataGui.Type,'Molecule') && isfield(Object,'Data')&&~isempty(Object.Data)
        Object.Data(Check==1)=[];     
    end
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
end
Check = false(size(Object.Results,1),1);
setappdata(hDataGui.fig,'Tags',Tags);
setappdata(hDataGui.fig,'Check',Check);
if hDataGui.BackUp==1
    RefreshData(hDataGui,-1);
end

function Switch(hDataGui)
global Filament;
switchtags = 1;
if strcmp(hDataGui.Type,'Filament')==1
    Object = getappdata(hDataGui.fig,'Object');
    Check = getappdata(hDataGui.fig,'Check');
    Tags = getappdata(hDataGui.fig,'Tags');
    TagsStart = Tags(:,6:8);
    PosStart = Object.PosStart;
    PosEnd = Object.PosEnd;
    Orientation = Object.Results(:,9);
    k = find(Check==1)';
    complete = 0;
    if isempty(k)
        complete = 1;
        k = 1:length(Check);
        for n = 1:length(Object.Data)
            Object.Data{n} = flipud(Object.Data{n});
        end
    end
    for n = k
        if hDataGui.Extensions.JochenK.DynTags && switchtags
            Tags(n,6:8) = Tags(n,9:11);
            Tags(n,9:11) = TagsStart(n,:);
        end
        if ~complete
            Object.Data{n} = flipud(Object.Data{n});
        end
        Orientation(n) = mod(Orientation(n)+pi,2*pi);
        PosStart(n,:) = Object.PosEnd(n,:);
        PosEnd(n,:) = Object.PosStart(n,:);    
    end
    if all(Object.PosStart(:,1:2)==Object.Results(:,3:4))
        Object.Results(:,3:5)=PosStart;
    elseif all(Object.PosEnd(:,1:2)==Object.Results(:,3:4))
        Object.Results(:,3:5) = PosEnd;
    end
    Object.PosStart = PosStart;
    Object.PosEnd = PosEnd;    
    Object.Results(:,9) = Orientation;
    if hDataGui.Extensions.JochenK.DynTags
        setappdata(hDataGui.fig,'Tags',Tags);
        Object.Results(k,end) = fJKtags2float(Tags(k,:));
    end
    Filament(hDataGui.idx) = Object;        
    Check(:) = 0;
    setappdata(hDataGui.fig,'Check',Check);
    RefreshData(hDataGui,0);
end
ReturnFocus([],[]);

function Split(hDataGui)
%done
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
fShared('BackUp',hMainGui);
Object=getappdata(hDataGui.fig,'Object');
Check = getappdata(hDataGui.fig,'Check');
if sum(Check)<length(Check)
    Object.Results(Check==0,:)=[];
    Object.Results(:,6)=fDis(Object.Results);
    if strcmp(hDataGui.Type,'Filament')==1
        Object.PosCenter(Check==0,:)=[];   
        Object.PosStart(Check==0,:)=[];
        Object.PosEnd(Check==0,:)=[];
        Object.Data(Check==0)=[];
    end
    if ~isempty(Object.PathData)
        Object.PathData(Check==0,:)=[];      
    end
    Object.Name=sprintf('New %s',Object.Name);
    if strcmp(hDataGui.Type,'Molecule')
        Molecule(length(Molecule)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData,Molecule,hMainGui.Menu.ctListMol,hMainGui.Values.MaxIdx);%JochenK
    elseif strcmp(hDataGui.Type,'Filament')
        Filament(length(Filament)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData,Filament,hMainGui.Menu.ctListFil,hMainGui.Values.MaxIdx);%JochenK
    end
    hDataGui.BackUp=0;
    DeletePoints(hDataGui);
    RefreshData(hDataGui,0,1);
end
set(hDataGui.bNext,'Enable','on');
ReturnFocus([],[]);

function Drift(hDataGui)
%done except for expanded
global Molecule;
global Filament;
Object=getappdata(hDataGui.fig,'Object');
Tags=getappdata(hDataGui.fig,'Tags');
if any(Tags(:,2))
    warndlg('Object is expanded.');
    set(hDataGui.cDrift,'Value',Object.Drift);
    return
end
if ~Object.TformMat(3,3)
    answer = questdlg('Object is color-aligned. Maybe you should first unalign it by clicking the "Align" checkbox. Continue anyway?', 'Warning', 'Yes','No','No' );
    if strcmp(answer, 'No')
        set(hDataGui.cDrift,'Value',Object.Drift);
        return
    end
end
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
if length(Drift)<Object.Channel
    set(hDataGui.cDrift,'Value',Object.Drift);
    warndlg('No drift loaded for this channel');
    return
end
if ~isempty(Drift)
    Object=fCalcDrift(Object, Drift{Object.Channel}, get(hDataGui.cDrift,'Value'));
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    RefreshData(hDataGui,0);
end
fRightPanel('CheckDrift',hMainGui);
ReturnFocus([],[]);

function [lXaxis,lYaxis]=CreatePlotList(Object,Type, ref, tags)
%create list for X-Axis
vel=CalcVelocity(Object);
n=4;
lXaxis.list{1}='x-position';
lXaxis.data{1}=Object.Results(:,3);
lXaxis.units{1}='[nm]';
lXaxis.list{2}='time';
lXaxis.data{2}=Object.Results(:,2);
lXaxis.units{2}='[s]';
lXaxis.list{3}='distance(to origin)';
lXaxis.data{3}=Object.Results(:,6);
lXaxis.units{3}='[nm]';
if ~isempty(Object.PathData)
    lXaxis.list{n}='distance(along path)';
    lXaxis.data{n}=real(Object.PathData(:,4));
    lXaxis.units{n}='[nm]';
    n=n+1;
end
lXaxis.list{n}='histogram';
lXaxis.data{n}=[];

%create Y-Axis list for xy-plot
lYaxis(1).list{1}='y-position';
lYaxis(1).data{1}=Object.Results(:,4);
lYaxis(1).units{1}='[nm]';

%create Y-Axis list for time plot
n=2;
lYaxis(2).list{1}='distance(to origin)';
lYaxis(2).data{1}=Object.Results(:,6);
lYaxis(2).units{1}='[nm]';
if ~isempty(Object.PathData)
    lYaxis(2).list{n}='distance(along path)';
    lYaxis(2).data{n}=real(Object.PathData(:,4));
    lYaxis(2).units{n}='[nm]';
    lYaxis(2).list{n+1}='sideways(to path)';
    lYaxis(2).data{n+1}=Object.PathData(:,5);
    lYaxis(2).units{n+1}='[nm]';
    n=n+2;
    if ~any(isnan(Object.PathData(:,6)))
        lYaxis(2).list{n}='height (above path)';
        lYaxis(2).data{n}=Object.PathData(:,6);   
        lYaxis(2).units{n}='[nm]';
        n=n+1;   
    end
end

lYaxis(2).list{n}='velocity';
lYaxis(2).data{n}=vel;
lYaxis(2).units{n}='[nm/s]';
n=n+1;

lYaxis(2).list{n}='distance to reference';
lYaxis(2).units{n}='[NA]';
refdata=fJKGetRefData(Object, ref, tags);
if any(~isnan(refdata))
    lYaxis(2).data{n}=refdata;
    lYaxis(2).units{n}='[nm]';
else
    refdata=nan;
    lYaxis(2).data{n}=zeros(size(Object.Results,1),1);
end
n=n+1;
vel=CalcVelocityRef(Object, refdata);
lYaxis(2).list{n}='velocity to reference';
if any(vel)
    lYaxis(2).units{n}='[nm/s]';
else
    lYaxis(2).units{n}='[NA]';
end
lYaxis(2).data{n}=vel;
n=n+1;

if strcmp(Type,'Molecule')==1
    if strcmp(Object.Type,'symmetric')
        lYaxis(2).list{n}='width(FWHM)';
    else
        lYaxis(2).list{n}='average width(FWHM)';
    end
    lYaxis(2).data{n}=Object.Results(:,7);
    lYaxis(2).units{n}='[nm]';    
    lYaxis(2).list{n+1}='amplitude';
    lYaxis(2).data{n+1}=Object.Results(:,8);
    lYaxis(2).units{n+1}='[ABU]';    
    n=n+2;
    if strcmp(Object.Type,'symmetric')
        lYaxis(2).list{n}='intensity(volume)';
        lYaxis(2).data{n}=2*pi*(Object.Results(:,7)/Object.PixelSize/(2*sqrt(2*log(2)))).^2.*Object.Results(:,8);       
        lYaxis(2).units{n}='[ABU]';        
        n=n+1;
    end
else
    lYaxis(2).list{n}='length';
    lYaxis(2).data{n}=Object.Results(:,7);       
    lYaxis(2).units{n}='[nm]';       
    lYaxis(2).list{n+1}='average amplitude';
    lYaxis(2).data{n+1}=Object.Results(:,8);
    lYaxis(2).units{n+1}='[ABU]';        
    lYaxis(2).list{n+2}='orientation(angle to x-axis)';
    lYaxis(2).data{n+2}=Object.Results(:,9);
    lYaxis(2).units{n+2}='[rad]';        
    n=n+3;
end

lYaxis(2).list{n}='x-position';
lYaxis(2).data{n}=Object.Results(:,3);
lYaxis(2).units{n}='[nm]';
lYaxis(2).list{n+1}='y-position';
lYaxis(2).data{n+1}=Object.Results(:,4);   
lYaxis(2).units{n+1}='[nm]';
n=n+2;
if ~any(isnan(Object.Results(:,5)))
    lYaxis(2).list{n}='z-position';
    lYaxis(2).data{n}=Object.Results(:,5);   
    lYaxis(2).units{n}='[nm]';
    n=n+1;    
end
if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='fit error of center';
    lYaxis(2).data{n}=Object.Results(:,9);        
    lYaxis(2).units{n}='[nm]'; 
    n=n+1;
    if strcmp(Object.Type,'streched')
        lYaxis(2).list{n}='width of major axis(FWHM)';
        lYaxis(2).data{n}=Object.Results(:,10);   
        lYaxis(2).units{n}='[nm]';        
        lYaxis(2).list{n+1}='width of minor axis(FWHM)';
        lYaxis(2).data{n+1}=Object.Results(:,11);      
        lYaxis(2).units{n+1}='[nm]';              
        lYaxis(2).list{n+2}='orientation(angle to x-axis)';    
        lYaxis(2).data{n+2}=Object.Results(:,12);      
        lYaxis(2).units{n+2}='[rad]';              
    elseif strcmp(Object.Type,'ring1')
        lYaxis(2).list{n}='radius ring';
        lYaxis(2).data{n}=Object.Results(:,10);      
        lYaxis(2).units{n}='[nm]';                    
        lYaxis(2).list{n+1}='amplitude ring';
        lYaxis(2).data{n+1}=Object.Results(:,11);                
        lYaxis(2).units{n+1}='[ABU]';                    
        lYaxis(2).list{n+2}='width (FWHM) ring';   
        lYaxis(2).data{n+2}=Object.Results(:,12);                
        lYaxis(2).units{n+2}='[nm]';        
    end
end

%create Y-Axis list for distance plot
lYaxis(3)=lYaxis(2);
lYaxis(3).list(1)=[];
lYaxis(3).data(1)=[];
lYaxis(3).units(1)=[];
n=4;
if ~isempty(Object.PathData)
    lYaxis(3).list(1)=[];
    lYaxis(3).data(1)=[];
    lYaxis(3).units(1)=[];
    lYaxis(4)=lYaxis(3);
    n=5;
end

%create list for histograms
lYaxis(n).list{1}='velocity';
lYaxis(n).units{1}='[nm/s]';
lYaxis(n).data{1}=[];

lYaxis(n).list{2}='pairwise-distance';
lYaxis(n).units{2}='[nm]';
lYaxis(n).data{2}=[];
k=3;
if ~isempty(Object.PathData)
    lYaxis(n).list{k}='pairwise-distance (path)';
    lYaxis(n).data{k}=[];
    lYaxis(n).units{k}='[nm]';
    k=k+1;
end

lYaxis(n).list{k}='amplitude';
lYaxis(n).units{k}='[ABU]';
lYaxis(n).data{k}=[];
if strcmp(Type,'Molecule')==1
    lYaxis(n).list{k+1}='intensity (volume)';
    lYaxis(n).units{k+1}='[ABU]';
    lYaxis(n).data{k+1}=[];
else
    lYaxis(n).list{k+1}='length';
    lYaxis(n).units{k+1}='[nm]';
    lYaxis(n).data{k+1}=[];
end


function CreateHistograms(hDataGui)
%unchanged
Object=getappdata(hDataGui.fig,'Object');
lYaxis=get(hDataGui.lYaxis,'UserData');
vel=CalcVelocity(Object);
n=length(lYaxis);
barchoice=[1 2 4 5 10 20 25 50 100 200 250 500 1000 2000 5000 10000 50000 10^5 10^6 10^7 10^8];

total=(max(vel)-min(vel))/15;
[~,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(vel)/barwidth)*barwidth-barwidth:barwidth:ceil(max(vel)/barwidth)*barwidth+barwidth;
num = hist(vel,x);
lYaxis(n).data{1}=[x' num']; 

XPos=Object.Results(:,3);
YPos=Object.Results(:,4);
ZPos=Object.Results(:,5);
if any(isnan(ZPos))
    ZPos(:)=0;
end
pairwise=zeros(length(XPos));
for i=1:length(XPos)
    pairwise(:,i)=sqrt((XPos-XPos(i)).^2 + (YPos-YPos(i)).^2 + (ZPos-ZPos(i)).^2);
end
p=tril(pairwise,-1);
pairwise=p(p>1);
x=round(min(pairwise)-10):1:round(max(pairwise)+10);
num = hist(pairwise,x);
lYaxis(n).data{2}=[x' num']; 
k=3;
if isfield(Object,'PathData')
    if ~isempty(Object.PathData)
        Dis=real(Object.PathData(:,4));
        pairwise=zeros(length(Dis));
        for i=1:length(Dis)
            pairwise(:,i)=Dis-Dis(i);
        end
        p=tril(pairwise,-1);
        pairwise=p(p>1);
        x=round(min(pairwise)-10):1:round(max(pairwise)+10);
        num = hist(pairwise,x);
        lYaxis(n).data{k}=[x' num']; 
        k=k+1;
    end
end

Amp=Object.Results(:,8);
total=(max(Amp)-min(Amp))/15;
[~,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(Amp)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Amp)/barwidth)*barwidth+barwidth;
num = hist(Amp,x);
lYaxis(n).data{k}=[x' num'];

if strcmp(hDataGui.Type,'Molecule')==1
    Int=2*pi*Object.Results(:,7).^2.*Object.Results(:,8);
    total=(max(Int)-min(Int))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Int)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Int)/barwidth)*barwidth+barwidth;
    num = hist(Int,x);
    lYaxis(n).data{k+1}=[x' num'];
else
    Len=Object.Results(:,7);
    total=(max(Len)-min(Len))/15;
    [~,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Len)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Len)/barwidth)*barwidth+barwidth;
    num = hist(Len,x);
    lYaxis(n).data{k+1}=[x' num'];
end
set(hDataGui.lYaxis,'UserData',lYaxis);


function XAxisList(hDataGui,zoomrefresh)
x=get(hDataGui.lXaxis,'Value');
y=get(hDataGui.lYaxis,'Value');
y2=get(hDataGui.lYaxis2,'Value');
s=get(hDataGui.lXaxis,'UserData');
a=get(hDataGui.lYaxis,'UserData');
enable='off';
enable2='off';
if x>1 && x<length(s.list)
    enable='on';
    if get(hDataGui.cYaxis2,'Value')==1
        enable2='on';
    end
end
if length(a(x).list)<y
    set(hDataGui.lYaxis,'Value',1);
end
if length(a(x).list)<y2
    set(hDataGui.lYaxis2,'Value',1);
end    
set(hDataGui.lYaxis,'String',a(x).list);
set(hDataGui.lYaxis2,'String',a(x).list);
set(hDataGui.cYaxis2,'Enable',enable);
set(hDataGui.tYaxis2,'Enable',enable2);
set(hDataGui.lYaxis2,'Enable',enable2);
if x==length(s.list) && isempty(a(x).data{1});
    CreateHistograms(hDataGui);
end
Draw(hDataGui,zoomrefresh);

function CheckYAxis2(hDataGui)
c=get(hDataGui.cYaxis2,'Value');
enable='off';
if c==1
    enable='on';
end
set(hDataGui.tYaxis2,'Enable',enable);
set(hDataGui.lYaxis2,'Enable',enable);
Draw(hDataGui,0);

function vel=CalcVelocity(Object)
XYZ = Object.Results(:,3:5);
nData=size(XYZ,1);
if any(isnan(XYZ(:,3)))
    XYZ(:,3)=0;
end
if nData>1
    vel=zeros(nData,1);
    vel(1)=sqrt(sum((XYZ(2,:)-XYZ(1,:)).^2))/(Object.Results(2,2)-(Object.Results(1,2)));
    vel(nData)=sqrt(sum((XYZ(nData,:)-XYZ(nData-1,:)).^2))/(Object.Results(nData,2)-(Object.Results(nData-1,2)));
    for i=2:nData-1
       vel(i)= (sqrt(sum((XYZ(i+1,:)-XYZ(i,:)).^2)) + sqrt(sum((XYZ(i,:)-XYZ(i-1,:)).^2)))/(Object.Results(i+1,2)-(Object.Results(i-1,2)));
    end
else
    vel=0;
end

function vel=CalcVelocityRef(Object, refdata)
nData=size(Object.Results,1);
if all(isnan(refdata))
    vel = zeros(size(Object.Results,1),1);
else
    track=[Object.Results(:,1:2) refdata];
    if nData>1
        vel=zeros(nData,1);
        vel(1)=(track(2,3)-(track(1,3))) /...
                     (track(2,2)-(track(1,2)));
        vel(nData)=(track(nData,3)-(track(nData-1,3))) /...
                     (track(nData,2)-(track(nData-1,2)));
        for i=2:nData-1
           vel(i)=(track(i,3)-(track(i-1,3))+track(i+1,3)-(track(i,3))) /...                    
                         (track(i+1,2)-(track(i-1,2)));
        end
    else
        vel=0;
    end
end

function Scroll(hObject,eventdata) %#ok<INUSL>
hDataGui=getappdata(0,'hDataGui');
set(0,'CurrentFigure',hDataGui.fig);
set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
pos = get(hDataGui.pPlotPanel,'Position');
cpFig = get(hDataGui.fig,'currentpoint');
cpFig = cpFig(1,[1 2]);
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cpFig>=[pos(1) pos(2)]) && all(cpFig<=[pos(1)+pos(3) pos(2)+pos(4)])
    Zoom=hDataGui.Zoom;
    if ~isempty(eventdata)
        level=Zoom.level-eventdata.VerticalScrollCount;
    else
        level=Zoom.level;
    end
    if level<1
        Zoom.currentXY=Zoom.globalXY;
        Zoom.level=0;
    else
        x_total=Zoom.globalXY{1}(2)-Zoom.globalXY{1}(1);
        y_total=Zoom.globalXY{2}(2)-Zoom.globalXY{2}(1);    
        x_current=Zoom.currentXY{1}(2)-Zoom.currentXY{1}(1);
        y_current=Zoom.currentXY{2}(2)-Zoom.currentXY{2}(1);        
        p=exp(-level/8);
        cp=cp(1,[1 2]);
        if strcmp(get(hDataGui.aPlot,'YDir'),'reverse');
            if (y_current/x_current) >= Zoom.aspect
                new_scale_y = y_total*p;
                new_scale_x = new_scale_y/Zoom.aspect;
            else
                new_scale_x = x_total*p;
                new_scale_y = new_scale_x*Zoom.aspect;
            end
        else
            new_scale_y = y_total*p;
            new_scale_x = x_total*p;
        end
        xy{1}=[cp(1)-(cp(1)-Zoom.currentXY{1}(1))/x_current*new_scale_x cp(1)+(Zoom.currentXY{1}(2)-cp(1))/x_current*new_scale_x];
        xy{2}=[cp(2)-(cp(2)-Zoom.currentXY{2}(1))/y_current*new_scale_y cp(2)+(Zoom.currentXY{2}(2)-cp(2))/y_current*new_scale_y];
        if xy{1}(1)<Zoom.globalXY{1}(1)
            xy{1}=xy{1}-xy{1}(1)+Zoom.globalXY{1}(1);
        end
        if xy{1}(2)>Zoom.globalXY{1}(2)
            xy{1}=xy{1}-xy{1}(2)+Zoom.globalXY{1}(2);
        end
        if xy{2}(1)<Zoom.globalXY{2}(1)
            xy{2}=xy{2}-xy{2}(1)+Zoom.globalXY{2}(1);
        end
        if xy{2}(2)>Zoom.globalXY{2}(2)
            xy{2}=xy{2}-xy{2}(2)+Zoom.globalXY{2}(2);
        end
        Zoom.currentXY=xy;
        Zoom.level=level;
    end
    set(hDataGui.aPlot,{'xlim','ylim'},Zoom.currentXY);
    hDataGui.Zoom=Zoom;
    setappdata(0,'hDataGui',hDataGui);
end

function RefreshData(hDataGui, varargin)
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
zoomrefresh=varargin{1};
idx=hDataGui.idx;
Type=hDataGui.Type;
eNext='on';
if idx==1
    ePrevious='off';
else
    ePrevious='on';
end
if strcmp(Type,'Molecule')
    if idx==length(Molecule)
        eNext = 'off';
    end    
    idx = min([idx length(Molecule)]);
    idx = max([1 idx]);
    Molecule(idx).Results(:,6) = fDis(Molecule(idx).Results(:,3:5));
    Object=Molecule(idx); 
    set(hDataGui.lReference,'enable','off');
else
    if idx==length(Filament)
        eNext = 'off';
    end
    idx = min([idx length(Filament)]);
    idx = max([1 idx]);
    Object=Filament(idx);
    set(hDataGui.lReference,'enable','on');
    switch get(hDataGui.lReference,'Value')
        case 1
            Object.Results(:,3:5) = Object.PosStart;
        case 2
            Object.Results(:,3:5) = Object.PosCenter;
        case 3
            Object.Results(:,3:5) = Object.PosEnd;
    end
    Object.Results(:,6) = fDis(Object.Results(:,3:5));
    Filament(idx)=Object;
end
Check=getappdata(hDataGui.fig,'Check');
if length(varargin)==2||length(Check)~=size(Object.Results,1)
    Check = false(size(Object.Results,1),1);
    setappdata(hDataGui.fig,'Check',Check);
end
Tags = getappdata(hDataGui.fig,'Tags');
if length(varargin)==2||size(Tags,1)~=size(Object.Results,1)||~strcmp(hDataGui.Name,Object.Name)
    Tags = fJKfloat2tags(Object.Results(:,end));
    setappdata(hDataGui.fig,'Tags',Tags);
    if length(varargin)~=2
        warning('Tags did not get refreshed where they should have (things are fine, but would not be if this object had as many frames as the former)');
    end
end
set(hDataGui.fig,'Name',Object.Name,'WindowStyle','normal','Visible','on');
set(hDataGui.tName,'String',Object.Name);
set(hDataGui.tFile,'String',Object.File);
set(hDataGui.tIndex,'String',['Index: ' num2str(idx)]);
set(hDataGui.bPrevious,'Enable',ePrevious);
set(hDataGui.bNext,'Enable',eNext);
set(hDataGui.eChannel,'String',num2str(Object.Channel));
set(hDataGui.eComments,'String',Object.Comments);
if isempty(Object.Comments)
    set(hDataGui.eComments,'String', 'Comments','ForegroundColor',[0.5 0.5 0.5],'HorizontalAlignment','center','Enable','inactive','ButtonDownFcn',@Clear);
else
    set(hDataGui.eComments,'String',Object.Comments,'Enable','on','ForegroundColor','k','HorizontalAlignment','left','ButtonDownFcn','');
end
set(hDataGui.cDrift,'Value',Object.Drift);
set(hDataGui.cAligned,'Value',~(Object.TformMat(3,3)==1));
set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));
setappdata(hDataGui.fig,'Object',Object);
refpoint=get(hDataGui.lReference,'Value');
X=Object.Results(:,3)/hMainGui.Values.PixSize;
Y=Object.Results(:,4)/hMainGui.Values.PixSize;
if length(X)==1
    X(1,2)=X;
    Y(1,2)=Y;
end
try
    if ishandle(Object.PlotHandles(1,1))
        set(Object.PlotHandles(1,1),'XData',X,'YData',Y);
        drawnow;
    end
catch
end
if hDataGui.Extensions.JochenK.DynTags && strcmp(Type,'Filament')
    switch refpoint
        case 1
            reftags = find(Tags(:, 6)==11);
        case 3
            reftags = find(Tags(:, 9)==11);
        otherwise
            reftags = find(Tags(:, 5)==11);
    end
else
    reftags = find(Tags(:, 5)==11);
    if isempty(reftags)
        reftags = 0;
    end
end
hDataGui.Name = Object.Name;
hDataGui.idx=idx;
setappdata(0,'hDataGui',hDataGui);
[lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type, refpoint, reftags);
set(hDataGui.lXaxis,'String',lXaxis.list);
set(hDataGui.lXaxis,'UserData',lXaxis);
set(hDataGui.lYaxis,'UserData',lYaxis);
set(hDataGui.lYaxis2,'UserData',lYaxis);
if get(hDataGui.cTable, 'Value')
    CreateTable(hDataGui,num2cell(Check), num2cell(Object.Results(:,[1,2,6])), Tags);
end
XAxisList(hDataGui,zoomrefresh);
if ~zoomrefresh
    delete(hDataGui.ZoomRegion.plot);    
    hDataGui.ZoomRegion.plot=[];
    hDataGui.CursorDownPos(:)=0;     
    hDataGui.CursorMode='Normal';
end
if gcbo == hDataGui.lTags
    hMainGui.Extensions.JochenK.ActiveTag = get(hDataGui.lTags, 'Value');
    setappdata(0,'hMainGui', hMainGui)
end
fRightPanel('UpdateKymoTracks',getappdata(0,'hMainGui'));
ReturnFocus([],[]);

function ZoomIn(hDataGui)
%JochenK
Object = getappdata(hDataGui.fig,'Object');
Check=getappdata(hDataGui.fig,'Check');
Tags = getappdata(hDataGui.fig,'Tags');
if sum(Check)
    if get(hDataGui.cTable, 'Value')
        tabledata=num2cell([find(Check==1), Object.Results(Check==1,[1,2,6])]);
        CreateTable(hDataGui,num2cell(true(sum(Check),1)),tabledata, Tags(Check==1,:));
    end
    Draw(hDataGui,-1);
end

function SelectValues(hDataGui) 
Object = getappdata(hDataGui.fig,'Object');
Tags = getappdata(hDataGui.fig,'Tags');
Check = false(size(Object.Results,1),1);
if gcbo == hDataGui.bSelectTags
    activetag = get(hDataGui.lTags, 'Value');
    if activetag>5 && hDataGui.Extensions.JochenK.DynTags && get(hDataGui.lReference,'Value')==3
        activetag=activetag+3;
    end
    Tags = Tags(:,activetag);
    answer = inputdlg('Enter tag value');
    values = Tags==str2double(answer);
else
    if gcbo == hDataGui.bSelectX
        if get(hDataGui.lXaxis,'Value')~=2
            plotted=get(hDataGui.DataPlot,'XData');
        else
            plotted = Object.Results(:,1);
        end
    else
        Y=get(hDataGui.DataPlot,'YData');
        if iscell(Y)
            plotted = Y{1};
        else
            plotted = Y;
        end
    end
    answer = fInputDlg({'Enter min value','Enter max value'},{num2str(min(plotted),10),num2str(max(plotted),10)});
    if isnan(str2double(answer{1})) || isnan(str2double(answer{2}))
        fMsgDlg('Wrong frame input','error');
        return;
    end
    values = plotted>=(str2double(answer{1})-1e-6)&plotted<=(str2double(answer{2})+1e-6);
end
Check(values) = 1;
setappdata(hDataGui.fig,'Check',Check);
Draw(hDataGui,-1);
ReturnFocus([],[]);

function Select(~, ~)
hDataGui=getappdata(0,'hDataGui');
data = get(hDataGui.tTable,'Data');
Check = cell2mat(data(:,1));
setappdata(hDataGui.fig,'Check',Check);
Draw(hDataGui,-1);
ReturnFocus([],[]);

function SelectAll(hDataGui) 
%Changed to work with "ZoomIn" (JochenK)
Object = getappdata(hDataGui.fig,'Object');
if get(gcbo,'UserData')==1
    Check = true(size(Object.Results,1),1);
else
    Check = false(size(Object.Results,1),1);
end
setappdata(hDataGui.fig,'Check',Check);
Tags = getappdata(hDataGui.fig,'Tags');
if get(hDataGui.cTable, 'Value')
    CreateTable(hDataGui,num2cell(Check), num2cell(Object.Results(:,[1,2,6])), Tags);
end
Draw(hDataGui,-1);
ReturnFocus([],[]);

function ReturnFocus(~,~)
hDataGui=getappdata(0,'hDataGui');
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
javaFrame = get(hDataGui.fig,'JavaFrame');
javaFrame.getAxisComponent.requestFocus;

function FitMissingPoints(hDataGui)
global Filament;
global Molecule;
global Config;
global Stack;
global TimeInfo;
persistent ConfigurationChecked
if isempty(Stack)
    fMsgDlg('Stack required','error');
    return;
end
if isempty(ConfigurationChecked) %JochenK. Also, this function does not backup anymore
    ConfigurationChecked = questdlg('Do you have your default configuration loaded? Some settings have effect on the outcome of this function, for example "Correct for focus drift". I will not ask again.', 'Warning', 'Yes','No','Yes' );
    if strcmp(ConfigurationChecked, 'No')
        return
    end
end
hMainGui = getappdata(0,'hMainGui');
Check = getappdata(hDataGui.fig,'Check');
CheckYes = find(Check==1);
idx=hDataGui.idx;
Type=hDataGui.Type;
if strcmp(Type,'Molecule')
    Object=Molecule(idx);
    params.find_molecules=0;
    params.find_beads=1;
else
    Object=Filament(idx);
    params.find_molecules=1;
    params.find_beads=0;
end
if Object.Drift == 1
    fMsgDlg('Not possible with Drift corrected tracks','error');
    return;
elseif ~(Object.TformMat(3,3)==1)
    fMsgDlg('Not possible with aligned tracks (undo offset correstion)','error');
    return;
elseif strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on')
    fMsgDlg('Stack already corrected.','error');
    return;
end
if sum(Check)
    answer = fInputDlg({'Enter starting frame','Enter last frame'},{num2str(Object.Results(CheckYes(1),1)),num2str(Object.Results(CheckYes(end),1))});
else
    answer = fInputDlg({'Enter starting frame','Enter last frame'},{num2str(Object.Results(1,1)),num2str(Object.Results(end,1))});
end
if isempty(answer) || isnan(str2double(answer{1})) || isnan(str2double(answer{2}))
    fMsgDlg('Wrong frame input','error');
    return;
end
fitframes = str2double(answer{1}):str2double(answer{2});
k = ismember(fitframes',Object.Results(:,1));
fitframes = fitframes(~k);
if ~isempty(fitframes)
    Check = false(size(Object.Results,1),1);
    Tags = getappdata(hDataGui.fig,'Tags');
    params.dynamicfil = 0;
    params.transform = hMainGui.Values.TformChannel{Object.Channel};
    params.bead_model=Config.Model;
    params.max_beads_per_region=Config.MaxFunc;
    params.scale=Config.PixSize;
    params.ridge_model = 'quadratic';
    params.area_threshold=Config.Threshold.Area;
    params.height_threshold=Config.Threshold.Height;
    params.fwhm_estimate=Config.Threshold.FWHM;
    params.border_margin=0;
    params.include_data=Config.OnlyTrack.IncludeData;
    if isempty(Config.ReduceFitBox)
        params.reduce_fit_box = 1;
    else
        params.reduce_fit_box = Config.ReduceFitBox;
    end
    params.focus_correction = Config.FilFocus;
    params.min_cod=Config.Threshold.Fit;
    params.threshold = 0;
    params.binary_image_processing = [];
    params.background_filter='none';
    params.display = 0;
    params.options = optimset( 'Display', 'off');
    params.options.MaxFunEvals = [];
    params.options.MaxIter = [];
    params.options.TolFun = [];
    params.options.TolX = [];
    if length(TimeInfo)>=Object.Channel && ~isempty(TimeInfo{Object.Channel})
        params.creation_time_vector = (TimeInfo{Object.Channel}-TimeInfo{Object.Channel}(1))/1000;
        %check wether imaging was done during change of date
        k = params.creation_time_vector<0;
        params.creation_time_vector(k) = params.creation_time_vector(k) + 24*60*60;
    end
    h=progressdlg('String',sprintf('Tracking - Frame: %d',fitframes(1)),'Min',1,'Max',length(fitframes),'Cancel','on','Parent',hDataGui.fig);
    for n = fitframes
        I = Stack{Object.Channel}(:,:,n);
        [y,x] = size(I);
        idx = [find(Object.Results(:,1)<n,1,'last') find(Object.Results(:,1)>n,1,'first')];
        if numel(idx)<2
            if idx(1)==1
                idx(2) = 2;
                s = 0;
                e = 1;
            else
                idx(2) = idx(1)-1;
                s = idx(1);
                e = idx(1)+1;
            end
        else
            s = idx(1);
            e = idx(2);
        end
        c = (n-Object.Results(idx(1),1))/(Object.Results(idx(2),1)-Object.Results(idx(1),1));
        if strcmp(Type,'Molecule')
            X = round( (Object.Results(idx(1),3)*(1-c)+Object.Results(idx(2),3)*c)/params.scale);
            Y = round( (Object.Results(idx(1),4)*(1-c)+Object.Results(idx(2),4)*c)/params.scale);
        else
            nData(1) = size(Object.Data{idx(1)},1);
            nData(2) = size(Object.Data{idx(2)},1);
            fX = zeros(max(nData),2);
            fY = zeros(max(nData),2);
            for m = 1:2
                if nData(m) ~=max(nData)
                    new_vector = 1:(nData(m)-1)/(max(nData)-1):nData(m);
                    old_vector = 1:nData(m);
                    fX(:,m) = interp1(old_vector,Object.Data{idx(m)}(:,1),new_vector);
                    fY(:,m) = interp1(old_vector,Object.Data{idx(m)}(:,2),new_vector);
                else
                    fX(:,m) = Object.Data{idx(m)}(:,1);
                    fY(:,m) = Object.Data{idx(m)}(:,2);
                end
            end
            X = round( (fX(:,1)*(1-c) + fX(:,2)*c)/params.scale);
            Y = round( (fY(:,1)*(1-c) + fY(:,2)*c)/params.scale);
        end
        k = X<1 | X>x | Y<1 | Y>y;
        X(k) = [];
        Y(k) = [];
        fidx = Y + (X - 1).*y;
        bw_region = zeros(size(I));
        bw_region(fidx) = 1;
        SE = strel('disk', ceil(params.fwhm_estimate/2/params.scale) , 4);
        params.bw_region = imdilate(bw_region(:,:,1),SE);
        Obj = ScanImage(I,params,n);
        if ~isempty(Obj) && numel(Obj)<2
            if strcmp(Type,'Molecule') && isempty(Obj.data{1})
                Check = [Check(1:s); 1; Check(e:end)];
                Tags = [Tags(1:s,:); [1 zeros(1,10)]; Tags(e:end,:)];
                Object.Results = [Object.Results(1:s,:); zeros(1,size(Object.Results,2)); Object.Results(e:end,:)];
                Object.Results(s+1,1) = single(n);
                Object.Results(s+1,2) = Obj.time;
                Object.Results(s+1,3) = Obj.center_x(1);
                Object.Results(s+1,4) = Obj.center_y(1);
                Object.Results(s+1,5) = NaN;
                Object.Results(s+1,7) = Obj.width(1,1);
                Object.Results(s+1,8) = Obj.height(1,1);
                Object.Results(s+1,9) = single(sqrt((Obj.com_x(2,1))^2+(Obj.com_y(2,1))^2));
                try
                    if strcmp(Object.Type,'stretched')
                        Object.Results(s+1,9:10) = Obj.data{1}';
                        Object.Results(s+1,11) = single(mod(Obj.orientation(1,1),2*pi));
                        Object.Results(s+1,12) = 1;
                    elseif strcmp(Object.Type,'ring1')
                        Object.Results(s+1,9:11) = Obj.data{1}(1,:);
                        Object.Results(s+1,12) = 1;
                    else
                        Object.Results(s+1,10) = 1;
                    end
                catch
                    Object.Results(s+1,10) = 1;
                    if size(Object.Results,2)>10
                        Object.Results(:,11:end) = [];
                    end
                end
                if Config.OnlyTrack.IncludeData == 1
                    Object.TrackingResults = [Object.TrackingResults(1:s) Obj.points{1} Object.TrackingResults(e:end)];
                else
                    Object.TrackingResults = [Object.TrackingResults(1:s) cell(1,1) Object.TrackingResults(e:end)];
                end  
            elseif strcmp(Type,'Filament') && ~isempty(Obj.data{1})
                Check = [Check(1:s); 1; Check(e:end)];
                Tags = [Tags(1:s,:); [1 zeros(1,10)]; Tags(e:end,:)];
                Object.Results = [Object.Results(1:s,:); zeros(1,size(Object.Results,2)); Object.Results(e:end,:)];
                Object.Results(s+1,1) = single(n);
                Object.Results(s+1,2) = Obj.time;
                Object.Results(s+1,3) = Obj.center_x(1);
                Object.Results(s+1,4) = Obj.center_y(1);
                Object.Results(s+1,5) = NaN;
                Object.Results(s+1,7) = Obj.length(1,1);
                Object.Results(s+1,8) = Obj.height(1,1);
                Object.Results(s+1,9) = single(mod(Obj.orientation(1,1),2*pi));
                Object.Results(s+1,10) = 1;
                data = [Obj.data{1}(:,1:2) ones(size(Obj.data{1},1),1)*NaN Obj.data{1}(:,3:end)];
                Object.Data = [Object.Data(1:s) data Object.Data(e:end)];
                Object.PosCenter = [Object.PosCenter(1:s,:); Object.Results(s+1,3:4) NaN; Object.PosCenter(e:end,:)];
                Object.PosStart = []; %[Object.PosStart(1:s,:); data(1,1:3); Object.PosStart(e:end,:)];
                Object.PosEnd = []; %[Object.PosEnd(1:s,:); data(end,1:3); Object.PosEnd(e:end,:)];
                Object = fAlignFilament(Object,Config);
                if Config.OnlyTrack.IncludeData == 1
                    Object.TrackingResults = [Object.TrackingResults(1:s) Obj.points{1} Object.TrackingResults(e:end)];
                else
                    Object.TrackingResults = [Object.TrackingResults(1:s) cell(1,1) Object.TrackingResults(e:end)];
                end  
            end
        end
        if isempty(h)
            break %JochenK
        end
        t = find(n==fitframes);
        if t<length(fitframes)
            h=progressdlg(t,sprintf('Tracking - Frame: %d',fitframes(t+1)));
        end
    end
    progressdlg('close');
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    setappdata(hDataGui.fig,'Tags',Tags);
    setappdata(hDataGui.fig,'Check',Check);
    RefreshData(hDataGui,0);
end

function FixOrientation(hDataGui)
global Filament;
if strcmp(hDataGui.Type,'Filament')==1
    hMainGui=getappdata(0,'hMainGui');
    fShared('BackUp',hMainGui);
    Object=getappdata(hDataGui.fig,'Object');
    Check = getappdata(hDataGui.fig,'Check');
    PosStart=Object.PosStart;
    PosEnd=Object.PosEnd;
    Orientation=Object.Results(:,9);
    k = find(Check==1)';
    if isempty(k)
        k = 1:length(Orientation);
    end
    for n = k(k>1)
        medianstart = median(PosStart(max(1, n-10):n-1,1:2),1);
        medianend = median(PosEnd(max(1, n-10):n-1,1:2),1);
        if CalcDistance(Object.Data{n}(1,1:2),medianstart)>CalcDistance(Object.Data{n}(1,1:2),medianend)
            Object.Data{n}=flipud(Object.Data{n});
        end
        if CalcDistance(Object.Data{n}(1,1:3),PosStart(n,:))>CalcDistance(Object.Data{n}(1,1:3),PosEnd(n,:))
            PosEnd(n,:)=Object.Data{n}(1,1:3);
            PosStart(n,:)=Object.Data{n}(end,1:3);
        else
            PosStart(n,:)=Object.Data{n}(1,1:3);
            PosEnd(n,:)=Object.Data{n}(end,1:3);
        end
%         if CalcDistance(PosStart(n,:),PosStart(1,:))+CalcDistance(PosEnd(n,:),PosEnd(1,:))>CalcDistance(PosStart(n,:),PosEnd(1,:))+CalcDistance(PosStart(n,:),PosEnd(1,:))
%             tmp=PosStart(n,:);
%             PosStart(n,:)=PosEnd(n,:);
%             PosEnd(n,:)=tmp;  
%         end
        if abs(Orientation(n)-Orientation(n-1))>4*pi/5
            tmp=[Orientation(n)+2*pi Orientation(n)-2*pi];
            [~,idx]=min(abs(tmp-Orientation(1)));
            Orientation(n)=tmp(idx);
        end
        if abs(Orientation(n)-Orientation(n-1))>pi/2
            Orientation(n)=mod(Orientation(n)+pi,2*pi);
        end
    end
    Object.PosStart=PosStart;
    Object.PosEnd=PosEnd;    
    Object.Results(:,9)=Orientation;   
    Filament(hDataGui.idx)=Object;
    RefreshData(hDataGui,0);
end
ReturnFocus([],[]);

function euclideanDistance = CalcDistance(p1, p2)
euclideanDistance=zeros(size(p1,1),1);
for i=1:size(p1,1)
    euclideanDistance(i) = sqrt((p2(i,1)-p1(i,1))^2+(p2(i,2)-p1(i,2))^2);
end

function InterpolateTrack(hDataGui)
global Filament
global TimeInfo;
fShared('BackUp',getappdata(0,'hMainGui'));
Object = getappdata(hDataGui.fig,'Object');
Tags = getappdata(hDataGui.fig,'Tags');
interpolated = logical(Tags(:,2));
if any(interpolated)
    copynumber = (length(interpolated)-1)/(sum(~interpolated)-1);
    Object.PosStart=Object.PosStart(~interpolated,:);
    Object.PosCenter=Object.PosCenter(~interpolated,:);
    Object.PosEnd=Object.PosEnd(~interpolated,:);
    Object.Results=Object.Results(~interpolated,:);
    Object.Results(:,1)=round((Object.Results(:,1)-1)/copynumber+1);
    Object.Results(:,2)=(TimeInfo{Object.Channel}(Object.Results(:,1))-TimeInfo{Object.Channel}(1))./1000;
    Filament(hDataGui.idx)=Object;
else
    if isempty(hDataGui.Extensions.JochenK.CopyNumber)
        copynumber = str2double(inputdlg('How many frames in channel 1 per frame in Object Channel (choice is kept until you close the Data GUI)?', '?', 1, {'40'}));
        hDataGui.Extensions.JochenK.CopyNumber = copynumber;
        setappdata(0,'hDataGui',hDataGui);
    else
        copynumber = hDataGui.Extensions.JochenK.CopyNumber;
    end
    fJKDynamicUtility('JKInterpolateTrack', copynumber, hDataGui.idx);
end
RefreshData(hDataGui,0,1)