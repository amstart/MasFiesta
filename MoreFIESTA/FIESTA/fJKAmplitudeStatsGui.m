function fJKAmplitudeStatsGui(func,varargin)
%This is a slightly modified version of fVelocityStatsGui
if nargin == 0
    func = 'Create';
end
switch func
    case 'Create'
        Create;
    case 'Calculate'
        Calculate(varargin{1});               
    case 'Save'
        Save;   
    case 'Export'
        Export;   
    case 'Update'
        Update;  
    case 'FitGauss'
        FitGauss;  
    case 'Draw'
        Draw(varargin{1});
end

function Create
global Molecule;
global Filament;

% h=findobj('Tag','hAmplitudeStatsGui');
% close(h)

MolSelect = [Molecule.Selected];
FilSelect = [Filament.Selected];

if any(MolSelect) && any(FilSelect)
    fMsgDlg({'Molecules and filaments selected','Choose only molecules or only filaments'},'error');
    return;
elseif any(MolSelect)
    Objects=Molecule(MolSelect==1);
    hAmplitudeStatsGui.Mode = 'Molecule';
elseif any(FilSelect)
    Objects=Filament(FilSelect==1);
    hAmplitudeStatsGui.Mode = 'Filament';
else
    fMsgDlg('No track selected!','error');
    return;
end
    
hAmplitudeStatsGui.fig = figure('Units','normalized','WindowStyle','normal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Average Amplitude',...
                      'NumberTitle','off','Position',[0.4 0.3 0.2 0.3],'HandleVisibility','callback','Tag','hAmplitudeStatsGui',...
                      'Visible','off','Resize','off','Renderer', 'painters');

fPlaceFig(hAmplitudeStatsGui.fig,'big');

if ispc
    set(hAmplitudeStatsGui.fig,'Color',[236 233 216]/255);
end

c = get(hAmplitudeStatsGui.fig,'Color');

hAmplitudeStatsGui.pPlotPanel = uipanel('Parent',hAmplitudeStatsGui.fig,'Position',[0.4 0.55 0.575 0.42],'Tag','PlotPanel','BackgroundColor','white');

hAmplitudeStatsGui.aPlot = axes('Parent',hAmplitudeStatsGui.pPlotPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');

str=cell(length(Objects),1);
for i=1:length(Objects)
    str{i}=Objects(i).Name;
end

hAmplitudeStatsGui.lSelection = uicontrol('Parent',hAmplitudeStatsGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fJKAmplitudeStatsGui(''Draw'',getappdata(0,''hAmplitudeStatsGui''));',...
                                   'Position',[0.025 0.78 0.35 0.19],'String',str,'Style','listbox','Value',1,'Tag','lSelection');
                    
hAmplitudeStatsGui.pOptions = uipanel('Parent',hAmplitudeStatsGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.025 0.55 0.35 0.2],'Tag','pOptions','BackgroundColor',c);
                         
hAmplitudeStatsGui.tMethod = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.8 0.225 0.125],'String','Method:','Style','text','Tag','tMethod','HorizontalAlignment','left');                        
                         
hAmplitudeStatsGui.mMethod = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','Callback','fJKAmplitudeStatsGui(''Update'');',...
                             'Position',[0.3 0.8 0.65 0.125],'BackgroundColor','white','String',{'Bin Object Medians', 'Bin Frames'},'Style','popupmenu','Tag','mMethod');

hAmplitudeStatsGui.tData = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.65 0.225 0.125],'String','Data:','Style','text','Tag','tData','HorizontalAlignment','left');     

hAmplitudeStatsGui.mData = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','Callback','fJKAmplitudeStatsGui(''Update'');',...
                            'Position',[0.3 0.65 0.65 0.125],'BackgroundColor','white','String',{'Width/Length', 'Height'},'Style','popupmenu','Tag','mData','Enable','on');             
 
hAmplitudeStatsGui.tSmooth = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','BackgroundColor',c,...
                             'Position',[0.05 0.5 0.225 0.125],'String','Smooth:','Style','text','Tag','tSmooth','HorizontalAlignment','left'); 
                        
hAmplitudeStatsGui.mSmooth = uicontrol('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized','Callback','fJKAmplitudeStatsGui(''Update'');',...
                             'Position',[0.3 0.5 0.65 0.125],'BackgroundColor','white','String',{'none'},'Style','popupmenu','Tag','mSmooth','Enable','on');
                         
hAmplitudeStatsGui.aEquation = axes('Parent',hAmplitudeStatsGui.pOptions,'Units','normalized',....
                                  'Position',[0.05 .025 .9 .45],'Tag','aEquation','Visible','off');  
                              
hAmplitudeStatsGui.tMedian = uicontrol('Parent',hAmplitudeStatsGui.pOptions, 'String', 'Median:', 'Style','text','Units','normalized','HorizontalAlignment','left', 'Position',[0.05 0.3 0.225 0.125],'BackgroundColor',c);
hAmplitudeStatsGui.tMean = uicontrol('Parent',hAmplitudeStatsGui.pOptions, 'String', 'Mean:', 'Style','text','Units','normalized','HorizontalAlignment','left', 'Position',[0.05 0.175 0.225 0.125],'BackgroundColor',c);
                              
hAmplitudeStatsGui.eMedian = uicontrol('Parent',hAmplitudeStatsGui.pOptions, 'String', '', 'Style','edit','Units','normalized', 'Position',[0.3 0.3 0.175 0.125],'BackgroundColor','white');
hAmplitudeStatsGui.eMean = uicontrol('Parent',hAmplitudeStatsGui.pOptions, 'String', '', 'Style','edit','Units','normalized', 'Position',[0.3 0.175 0.175 0.125],'BackgroundColor','white');

% ShowEquation(hAmplitudeStatsGui)

hAmplitudeStatsGui.pResultsPanel = uipanel('Parent',hAmplitudeStatsGui.fig,'Position',[0.025 0.08 0.95 0.445],'Tag','PlotPanel','BackgroundColor','white');

hAmplitudeStatsGui.aResults = axes('Parent',hAmplitudeStatsGui.pResultsPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');
                        
hAmplitudeStatsGui.pButtons = uipanel('Parent',hAmplitudeStatsGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 0 1 0.07],'Tag','pNorm','Visible','on','BackgroundColor',c);
       
hAmplitudeStatsGui.bFitGauss = uicontrol('Parent',hAmplitudeStatsGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.025 .2 .2 .7],'Tag','bFitGauss','Fontsize',12,...
                              'String','Fit Gaussian','Callback','fJKAmplitudeStatsGui(''FitGauss'');');     
                          
hAmplitudeStatsGui.bSave = uicontrol('Parent',hAmplitudeStatsGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.325 .2 .2 .7],'Tag','bSave','Fontsize',12,...
                              'String','Save Data','Callback','fJKAmplitudeStatsGui(''Save'');');         
                          
hAmplitudeStatsGui.bExport = uicontrol('Parent',hAmplitudeStatsGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.55 .2 .2 .7],'Tag','bSave','Fontsize',12,...
                              'String','Export Histogram','Callback','fJKAmplitudeStatsGui(''Export'');');   
                          
hAmplitudeStatsGui.bClose = uicontrol('Parent',hAmplitudeStatsGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.775 .2 .2 .7],'Tag','bClose','Fontsize',12,...
                              'String','Close','Callback','close(findobj(0,''Tag'',''hAmplitudeStatsGui''));');                        
                                   
setappdata(0,'hAmplitudeStatsGui',hAmplitudeStatsGui);
setappdata(hAmplitudeStatsGui.fig,'Objects',Objects);
Update;
set(hAmplitudeStatsGui.fig,'Visible','on');

       
function Save
hAmplitudeStatsGui = getappdata(0,'hAmplitudeStatsGui');
Data = getappdata(hAmplitudeStatsGui.fig,'Data');
Units = getappdata(hAmplitudeStatsGui.fig,'Units');
[FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-File (*.mat)';'*.txt','TXT-File (*.txt)';},'Save Amplitude/Height Data',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if FilterIndex==1
        if isempty(strfind(file,'.mat'))
            file = [file '.mat'];
        end
        Histogram=Data.hist; %#ok<NASGU>
        Velocities=cell2mat(Data.amplength)'; %#ok<NASGU>
        Objects=cell(1,length(Data.amplength));
        for n=1:length(Data.amplength)
            Objects{n}=[Data.time{n}' Data.amplength{n}'];
        end
        if isfield(Data,'fit')
            GaussFit=Data.fit; %#ok<NASGU>
            save(file,'Histogram','Velocities','Objects','GaussFit');
        else
            save(file,'Histogram','Velocities','Objects');
        end
    else
        if isempty(strfind(file,'.txt'))
            file = [file '.txt'];
        end
        f = fopen(file,'w');
        fprintf(f,['Amplitude/Height Statistics for ' num2str(length(Data.amplength)) ' ' hAmplitudeStatsGui.Mode 's (' datestr(clock) ')\n']);
        fprintf(f,['Amplitude/Height(mean): ' num2str(mean(cell2mat(Data.amplength)),Units.fmt) ' ' char(177) ' ' num2str(std(cell2mat(Data.amplength)),Units.fmt) ' ' Units.str '(SD)\n']);
        if isfield(Data,'fit')
            params = coeffvalues(Data.fit);
            for n = 1:round(length(params)/3);
                fprintf(f,['Amplitude/Height(peak' num2str(n) '): ' num2str(params(3*n-1),Units.fmt) ' ' char(177) ' ' num2str(params(n*3)/sqrt(2),Units.fmt) ' ' Units.str '(SD)\n']); 
            end
        end
        fprintf(f,'\n');
        fprintf(f,'Histogram(center of bins)\n');
        fprintf(f,['Amplitude/Height[' Units.str '/s]\tfrequency[counts]\n']);
        for n = 1:size(Data.hist,1)
            fprintf(f,[Units.fmt '\t%9.0f\n'],Data.hist(n,1),Data.hist(n,2));
        end
        fprintf(f,'\n');
        fprintf(f,'velocities[nm/s]\n');
        vel = cell2mat(Data.amplength);
        for n = 1:length(vel)
            fprintf(f,[Units.fmt '\n'],vel(n));
        end
        fclose(f);
    end  
    fShared('SetSaveDir',PathName);
end

function Export
hAmplitudeStatsGui = getappdata(0,'hAmplitudeStatsGui');
Data = getappdata(hAmplitudeStatsGui.fig,'Data');
Units = getappdata(hAmplitudeStatsGui.fig,'Units');
[FileName, PathName, FilterIndex] = uiputfile({'*.jpg','JPEG-File (*.jpg)';'*.png','PNG-File (*.png)';'*.eps','EPS-File (*.eps)'},'Export Histogram',fShared('GetSaveDir'));
if FileName~=0
    file = [PathName FileName];
    hFig = figure('Visible','on');
    hAxes = axes('Parent',hFig,'TickDir','in');
    bar(hAxes,Data.hist(:,1),Data.hist(:,2),'BarWidth',1,'FaceColor',[179/255 199/255 1]); 
    if isfield(Data,'fit')
        hold on
        f = Data.fit;
        plot(f,'r-');
        params = coeffvalues(f);
        for m = 1:length(params)/3
            text(params(m*3-1),f(params(m*3-1))+max(Data.hist(:,2))*0.05,['Amplitude/Height: ' num2str(params(m*3-1),Units.fmt) ' ' char(177) ' ' num2str(params(m*3)/sqrt(2),Units.fmt) ' nm/s (SD)'],'VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','fit','FontSize',12,'FontWeight','normal','BackgroundColor','w');   
        end
        legend(hAxes,{'Velocities','Gaussian fit'},'Location','best');
    else
        legend(hAxes,{'Velocities'},'Location','best');
    end
    xlabel(hAxes,['Amplitude/Height [' Units.str '/s]']);
    ylabel(hAxes,'frequency [counts]');  
    barwidth = (Data.xy{1}(2)-Data.xy{1}(1))/size(Data.hist,1);
    if Data.hist(1,1)<0 && Data.hist(end,1)>0
        ticks = [fliplr(0:-2*barwidth:Data.hist(1,1)-barwidth/2) 2*barwidth:2*barwidth:Data.hist(end,1)+barwidth/2];
    else
        ticks = Data.hist(1,1)-barwidth/2:2*barwidth:Data.hist(end,1)+barwidth/2;
    end
    set(hAxes,{'xlim','ylim'},Data.xy,'XTick',ticks);
    box on;
    switch FilterIndex
        case 1
            if isempty(strfind(file,'.jpg'))
                file = [file '.jpg'];
            end
            print(hFig,'-djpeg','-r600',file);
        case 2
            if isempty(strfind(file,'.png'))
                file = [file '.png'];
            end
            print(hFig,'-dpng','-r600',file);
        case 3
            if isempty(strfind(file,'.eps'))
                file = [file '.eps'];
            end
            print(hFig,'-depsc','-cmyk',file);
    end
    delete(hFig);
    fShared('SetSaveDir',PathName);
end

function Update
hAmplitudeStatsGui = getappdata(0,'hAmplitudeStatsGui');
% ShowEquation(hAmplitudeStatsGui);
if get(hAmplitudeStatsGui.mSmooth,'Value')>1
    hAmplitudeStatsGui.SmoothBox = str2double(fInputDlg('Enter box size for smoothing using a rolling frame average','5'));
    if isnan(hAmplitudeStatsGui.SmoothBox)
        hAmplitudeStatsGui.SmoothBox = [];
        set(hAmplitudeStatsGui.mSmooth,'Value',1);
    end   
end
setappdata(0,'hAmplitudeStatsGui',hAmplitudeStatsGui);
Calculate(hAmplitudeStatsGui)


function Calculate(hAmplitudeStatsGui)
Objects = getappdata(hAmplitudeStatsGui.fig,'Objects');
amplength = cell(1,length(Objects));
time = cell(1,length(Objects));
if get(hAmplitudeStatsGui.mData, 'Value') == 1
    column = 7;
    Units.str = '\mum';
else
    column = 8;
    Units.str = 'AU';
end
for n = 1:length(Objects)
    amplength{n}=[];
    time{n}=[];
    if size(Objects(n).Results,1)>1
        amplength{n} = Objects(n).Results(:,column)';
        time{n} = Objects(n).Results(:,2)';
    end
end    
Data = [];
Units.val = 1;
Units.fmt = '%4.0f';
% for n=1:length(amplength)
%     amplength{n}=amplength{n}/Units.val;
% end
Data.amplength=amplength;
Data.time=time;
allamplength = cell2mat(Data.amplength);
set(hAmplitudeStatsGui.eMedian, 'String', int2str(median(allamplength)));
set(hAmplitudeStatsGui.eMean, 'String', int2str(mean(allamplength)));
setappdata(hAmplitudeStatsGui.fig,'Data',Data);
setappdata(hAmplitudeStatsGui.fig,'Units',Units);
Draw(hAmplitudeStatsGui)

function Draw(hAmplitudeStatsGui)
Objects = getappdata(hAmplitudeStatsGui.fig,'Objects');
Data = getappdata(hAmplitudeStatsGui.fig,'Data');
Units = getappdata(hAmplitudeStatsGui.fig,'Units');
nObject = get(hAmplitudeStatsGui.lSelection,'Value');
cla(hAmplitudeStatsGui.aPlot);
if isempty(Data.amplength{nObject})
    text(0.2,0.5,'No data available for current object','Parent',hAmplitudeStatsGui.aPlot,'FontWeight','bold','FontSize',16);
    set(hAmplitudeStatsGui.aPlot,'Visible','off');
    legend(hAmplitudeStatsGui.aPlot,'off');
else
    plot(hAmplitudeStatsGui.aPlot,Data.time{nObject},Data.amplength{nObject},'b-');
    legend(hAmplitudeStatsGui.aPlot,['Amplitude/Height: ' num2str(mean(Data.amplength{nObject}),Units.fmt) ' ' char(177) ' ' num2str(std(Data.amplength{nObject}),Units.fmt) ' ' Units.str ' (SD)'],'Location','best');
    xlabel(hAmplitudeStatsGui.aPlot,'time [s]');
    ylabel(hAmplitudeStatsGui.aPlot,['Amplitude/Height [' Units.str ']']);
    set(hAmplitudeStatsGui.aPlot,'Visible','on');
end
switch get(hAmplitudeStatsGui.mMethod,'Value')
    case 1
        amplength = zeros(length(Data.amplength), 1);
        for i = 1:length(Data.amplength)
            amplength(i) = median(Data.amplength{i});
        end
        SelectedValue = median(Data.amplength{nObject});
    case 2
        amplength = cell2mat(Data.amplength);
        SelectedValue = Data.amplength{nObject};
end
cla(hAmplitudeStatsGui.aResults);
% hAmplitudeStatsGui.aResults = axes('Parent',hAmplitudeStatsGui.pResultsPanel,'Units','normalized','OuterPosition',[0 0 1 1],'Tag','Plot','TickDir','in');
axes(hAmplitudeStatsGui.aResults);
hold(hAmplitudeStatsGui.aResults, 'on')
h = histogram(amplength);
barwidth = (h.BinEdges(2)-h.BinEdges(1))/2;
xout = h.BinEdges(1:end-1)+barwidth;
n = h.Values;
Data.hist = [xout' n'];
Data.xy = {[min(xout)-barwidth/2 max(xout)+barwidth/2],[0 max(n)*1.2]};
bar(hAmplitudeStatsGui.aResults, xout,n,'BarWidth',1,'FaceColor',[0 0 0.5]); 
% set(hAmplitudeStatsGui.aResults,{'xlim','ylim'},Data.xy);
counts = histcounts(SelectedValue, h.BinEdges);
bar(hAmplitudeStatsGui.aResults,xout,counts,'BarWidth',1,'FaceColor',[179/255 199/255 1]); 
xlabel(hAmplitudeStatsGui.aResults,['Amplitude/Height [' Units.str ']']);
ylabel(hAmplitudeStatsGui.aResults,'frequency [counts]');
legend(hAmplitudeStatsGui.aResults,{'current object', 'all objects'},'Location','best');
setappdata(hAmplitudeStatsGui.fig,'Data',Data);
stepsize = ceil(length(xout)/10);
set(hAmplitudeStatsGui.aResults,'XTick',xout(1:stepsize:end));
set(hAmplitudeStatsGui.aResults,'XtickLabel',xout(1:stepsize:end));

function FitGauss
hAmplitudeStatsGui = getappdata(0,'hAmplitudeStatsGui');
Data = getappdata(hAmplitudeStatsGui.fig,'Data');
Units = getappdata(hAmplitudeStatsGui.fig,'Units');
set(hAmplitudeStatsGui.fig,'CurrentAxes',hAmplitudeStatsGui.aResults);
xout = Data.hist(:,1);
n = Data.hist(:,2);
legend(hAmplitudeStatsGui.aResults,'off');
delete(findobj('Parent',hAmplitudeStatsGui.aResults,'-and','Tag','fit'));
text(double(max(xout)-min(xout))/2,double(max(n)*1.1),'Choose peak(s) by left-click, press any key or right-click to continue.','VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','choose');  
k = 0;
p = 1;
while k == 0
    k = waitforbuttonpress;
    if k == 0 
        if strcmp(get(hAmplitudeStatsGui.fig,'SelectionType'),'normal')
            cp = get(hAmplitudeStatsGui.aResults,'CurrentPoint');
            x(p) = cp(1,1);
            p = p + 1;
        else
            k = 1;
        end
    end
end
if p>1
    mode = ['gauss' num2str(length(x))];
    params0 = zeros(1,length(x)*3);
    for m = 1:length(x)
        [~,t] = min(abs(x(m)-xout));
        params0(m*3-2) = n(t);
        params0(m*3-1) = xout(t);
        params0(m*3) = 2*(abs(xout(2)-xout(1)));
    end
    opt = fitoptions(mode,'Startpoint',params0);
    f = fit(xout,n,mode,opt);
    params = coeffvalues(f);
    Data.fit = f;
    delete(findobj('Parent',hAmplitudeStatsGui.aResults,'-and','Tag','choose'));
    hold on;
    h = plot(f,'r-');
    set(h,'Tag','fit');
    for m = 1:length(x)
        text(double(params(m*3-1)),double(f(params(m*3-1))+max(n)*0.05),['Amplitude: ' num2str(params(m*3-1),Units.fmt) ' ' char(177) ' ' num2str(params(m*3)/sqrt(2),Units.fmt) ' ' Units.str '(SD)'],'VerticalAlignment','Bottom','HorizontalAlignment','center','Tag','fit','FontSize',12,'FontWeight','bold','BackgroundColor','w');   
    end
    set(hAmplitudeStatsGui.aResults,{'xlim','ylim'},Data.xy);
    legend(hAmplitudeStatsGui.aResults,{'all objects','current object','Gaussian fit'},'Location','best');
    xlabel(hAmplitudeStatsGui.aResults,['Amplitude [' Units.str ']']);
    ylabel(hAmplitudeStatsGui.aResults,'frequency [counts]');
    legend(hAmplitudeStatsGui.aPlot,'show');
    setappdata(hAmplitudeStatsGui.fig,'Data',Data);
else
    Draw(hAmplitudeStatsGui)
end

