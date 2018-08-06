function fJKDynamicFilamentsGui(func,varargin)
if nargin == 0 || any(ishandle(func))
    DF.createGui(varargin{:});
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
        DF.createGui(varargin{:});
    case 'SetTable'
        SetTable;           
    case 'SetMenu'
        SetMenu(varargin{:}); 
    case 'Save'
        Save;   
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
    case 'DF.Draw'
        DF.Draw(varargin{:});
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

function LoadOptions(varargin)
global DFDir
hDFGui = getappdata(0,'hDFGui');
try
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Options',DFDir);
catch
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Options');        
end
DFDir=PathName;
Options = load([PathName FileName], 'Options');
Options = Options.Options;
children = get(hDFGui.pOptions, 'Children');
children = vertcat(children, get(hDFGui.pLoadOptions, 'Children'));
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
[Objects, Tracks] = hDFGui.Segment(Options);
setappdata(hDFGui.fig,'Tracks', Tracks);
setappdata(hDFGui.fig,'Objects',Objects);
DF.SetTable();


function Quicksave(varargin)
global DFDir
persistent QuicksaveDir
if nargin>0
    QuicksaveDir = [];
    return
end
if isempty(QuicksaveDir)
    try
        QuicksaveDir = uigetdir(DFDir, 'Select the quicksave folder (choice will be remembered until you refresh the GUI).');
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
    filename = inputdlg('Filename?', 'Filename?', 1, {[filename(1:optionsstart) ' ']});
    saveas(gcf,[QuicksaveDir filesep filename{1} '.png'], 'png');
%     savefig(gcf,[QuicksaveDir filesep strrep(get(gcf, 'Name'), ' | ', '_') '.fig']);
end


function AddCustomData(varargin)
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
[unique_paths, ~, MT_index] = unique(LoadedFromPath, 'stable');
filename = inputdlg('Filename (without .mat)? You will find the data under Object.Custom.<filename>', 'Filename?', 1, {'pixelkymo_GFP'});
filename = filename{1};
if ~isempty(strfind(filename, 'fit'))
    fun = @PrepareFitData;
    read_fun = @ReadFitData;
    prefix = strrep(filename, 'pixelkymo_', '');
    prefix = strrep(prefix, '_fit', '');
    plot_options = {[prefix ' error function width'], [prefix ' error function displacement']; 'pixels', 'pixels'};
elseif ~isempty(strfind(filename, 'pixelkymo'))
    fun = @PrepareKymoData;
    read_fun = [];
    plot_options = {};
elseif ~isempty(strfind(filename, 'tfi_intensity'))
    fun = @(x) x;
    read_fun = @ReadTFIData;
    plot_options = {'TFI MAP count'; '1'};
else
    fun = @(x) x;
    read_fun = [];
    plot_options = {};
end
progressdlg('String','Appending Custom Data','Min',0,'Max',length(unique_paths));
for m=1:length(unique_paths)
    try
        load_data = load([unique_paths{m} filename '.mat']);
        for n = find(MT_index == m)'
            Objects(n).CustomData.(filename).ScanOptions = load_data.ScanOptions;
            for p=1:size(load_data.Data,1) %find microtubule data by name in second column
                if strcmp(Objects(n).Name, load_data.Data{p, 2})
                    custom_data = load_data.Data{p, 1};
                    Objects(n).CustomData.(filename).Data = fun(custom_data);
                    Objects(n).CustomData.(filename).read_fun = read_fun;
                    Objects(n).CustomData.(filename).plot_options = plot_options;
                end
            end
        end
    progressdlg(m);
    catch
    end
end
setappdata(hDFGui.fig,'Objects',Objects);
DF.updateOptions();

function [matrix] = ReadTFIData(Object, customfield, Options)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 1);
for m = 1:length(data)
    if ~isnan(data{m})
        matrix(m) = sum(data{m}(1:Options.eIevalLength.val));
    end
end
for m = find(isnan(matrix(2:end-1)))+1
    matrix(m) = (matrix(m-1)+matrix(m+1))/2;
end
if isfield(Object.Custom, 'IntensityPerMAP')
    matrix = matrix./Object.Custom.IntensityPerMAP;
end

function [matrix] = ReadFitData(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 2);
for m = 1:length(data)
    if isstruct(data{m})
        matrix(m,1) = data{m}.w0;
        matrix(m,2) = data{m}.x0;
    end
end

function fit_data = PrepareFitData(fit_data)
for m = 1:length(fit_data)
    if ~isstruct(fit_data{m})
        fit_data{m} = nan;
        continue
    end
    tmp = fit_data{m}.gof;
    tmp.w0 = fit_data{m}.fitresult.w0;
    tmp.x0 = fit_data{m}.fitresult.x0;
    tmp.p0 = fit_data{m}.fitresult.p0;
    tmp.y0 = fit_data{m}.fitresult.y0;
    fit_data{m} = tmp;
end

function kymo_data = PrepareKymoData(kymo_data)
%simply takes the maximum pixel per "cross section" of the kymograph line
for m = 1:length(kymo_data)
    kymo_data{m} = max(kymo_data{m}, [], 1);
end

function Save
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
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
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
set(hDFGui.lSelection,'Value', 1:length(Objects));
DF.SetTable();

function Workspace
hDFGui = getappdata(0,'hDFGui');
selected = get(hDFGui.lSelection,'Value');
selected = unique(selected);
Objects = getappdata(hDFGui.fig,'Objects');
Objects = Objects(selected);
assignin('base', 'Objects', Objects)
Tracks = getappdata(hDFGui.fig,'Tracks');
selected_tracks = [];
for m = 1:length(Objects)
    selected_tracks = vertcat(selected_tracks, Objects(m).TrackIds);
end
selected_tracks = unique(selected_tracks);
Tracks = Tracks(selected_tracks(logical(selected_tracks)));
assignin('base', 'Tracks', Tracks)
'workspace updated'

function Delete
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
selected=get(hDFGui.lSelection,'Value');
keep=setxor(selected, 1:length(Objects));
keep = keep(keep<=length(Objects));
Objects = Objects(keep);
setappdata(hDFGui.fig,'Objects',Objects);
setappdata(0,'hDFGui',hDFGui);
DF.SetTable();


function LoadIntensityPerMAP(FileName, PathName)
%reads a table and matches values and associated objects
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
table = readtable([PathName FileName], 'Format', '%s%s%d', 'Delimiter','\t');
for i = 1:length(table.Value)
    if strcmp(table.Moviefolder(i),'all')
        changeobjects = cellfun(@(x) ~isempty(strfind(x, table.Folder{i})), LoadedFromPath);
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
setappdata(hDFGui.fig,'Objects',Objects);
setappdata(0,'hDFGui',hDFGui);

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


function SetMenu(hDFGui)
switch get(hDFGui.lChoosePlot, 'Value')
    case {1,2}
        set(hDFGui.mXReference, 'Visible', 'on');
        set(hDFGui.lSubsegment, 'Visible', 'on');
    case 7
        set(hDFGui.mXReference, 'Visible', 'off');
        set(hDFGui.lSubsegment, 'Visible', 'on');
    otherwise
        set(hDFGui.mXReference, 'Visible', 'off');
        set(hDFGui.lSubsegment, 'Visible', 'off');
end


function SurfPlot()
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
Options = getappdata(hDFGui.fig,'Options');
Selected=get(hDFGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    includepoints = ones(size(Object.Tags,1), 1);
    if ~Options.cIncludeUnclearPoints.val
        includepoints = includepoints & Object.Tags(:,1)~=8;
        includepoints = includepoints & Object.Tags(:,1)~=7;
    end
    if ~Options.cIncludeNonTypePoints.val
        includepoints = includepoints & Object.Tags(:,2)==0;
    end
    try
        customfields = fields(Object.CustomData);
        answer = listdlg('ListString', customfields, 'SelectionMode', 'single');
        kymo_field = customfields{answer};
        custom_data = Object.CustomData.(kymo_field).Data(includepoints)';
        figure('Name', ['Surf: ' Object.Name ' ' Object.File ' ' kymo_field])
    catch
        msgbox('you need to have kymograph data loaded in the field CustomData.pixelkymo');
        return
    end
    maxLength=max(cellfun(@(x)numel(x),custom_data));
    padded_matrix=cell2mat(cellfun(@(x)cat(2,x, nan(1,maxLength-length(x))),custom_data,'UniformOutput',false));
    surf(padded_matrix)
    colormap(linspecer_modified);
    hold on;
    zlabel('Intensity');
    ylabel('frame');
    xlabel('Arc length away from plus end [pixels]');
    l = Object.CustomData.(kymo_field).ScanOptions.help_get_tip_kymo.ExtensionLength;
    x_length = size(padded_matrix,1);
    z_min = min(max(padded_matrix(:,1:20,:)));
    z_max = max(max(padded_matrix(:,1:20,:)));
    set(gca, 'FontSize', 18, 'LabelFontSizeMultiplier', 1.5)
    v = patch([l l l l], [0 0 x_length x_length], [z_min z_max z_max z_min],[0.9, 0.9, 0.9]);
    set(v,'facealpha',0.3);
    set(v,'edgealpha',0.5);
    set(v,'edgecolor','red');
    try
        fit_data = Object.CustomData.([kymo_field '_fit']).Data(includepoints);
        fit_matrix = zeros(length(fit_data),2);
        values = zeros(length(fit_data),2);
        for m = 1:length(fit_data)
            if ~isstruct(fit_data{m})
                fit_matrix(m,:) = [nan nan];
                continue
            end
            fit_matrix(m,:) = [6+fit_data{m}.x0 6+fit_data{m}.w0+fit_data{m}.x0];
            values(m,1) = padded_matrix(m, 6+ceil(fit_matrix(m,1)));
            values(m,2) = padded_matrix(m, 6+ceil(fit_matrix(m,1))+ceil(fit_matrix(m,2)));
        end
        plot3(fit_matrix(:,1), 1:length(fit_data), values(:,1), 'r-');
%         plot3(fit_matrix(:,2), 1:length(fit_data), values(:,1), 'g-');
    catch
    end
end

function CustomPlot()
hDFGui = getappdata(0,'hDFGui');
var_units = get(hDFGui.lPlot_XVar, 'UserData');
var_names = get(hDFGui.lPlot_XVar, 'String');
Tracks = getappdata(hDFGui.fig,'Tracks');
Objects = getappdata(hDFGui.fig,'Objects');
Selected=get(hDFGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
if ~isempty(Objects)&&~isempty(Selected)
    Object = Objects(Selected(1));
    figure('Name', ['Custom Data: ' Object.Name ' ' Object.File])
    hold on;
    track_id=Object.SegTagAuto(:,5);
    track_id=track_id(track_id>0);
    tracks=Tracks(track_id);
    for m = 1:size(tracks(1).Data,2)-6
        subplot(size(tracks(1).Data,2)-6,1,m);
        hold on;
        for i=1:length(tracks)
            plot(tracks(i).Data(:,1),tracks(i).Data(:,m+6));
        end
        ylabel([var_names{m+6} ' [' var_units{m+6} ']']);
    end
    xlabel('time [s]');
end

function OpenInfo
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
Selected=get(hDFGui.lSelection,'Value');
Selected=Selected(Selected>0&Selected<length(Objects)+1);
Object = Objects(Selected(1));
if gcbo == hDFGui.bTIF
    OpenFile = [Object.LoadedFromPath Object.Name '.tif'];
elseif gcbo == hDFGui.bPDF
    OpenFile = [Object.LoadedFromPath Object.Name '.pdf'];
elseif gcbo == hDFGui.bTXT
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
elseif gcbo == hDFGui.bLOCATION
    OpenFile = [Object.LoadedFromPath 'maximum' '.tif'];
elseif gcbo == hDFGui.bFOLDER
    OpenFile = Object.LoadedFromPath;
elseif gcbo == hDFGui.bFIESTA
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

function UpdatePlot(hDFGui)
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
                set(hDFGui.lChoosePlot, 'Value', 2);
                userdatafixed = userdatafixed-100;
            else
                set(hDFGui.lChoosePlot, 'Value', 1);
            end
            set(hDFGui.lPlot_XVar, 'Value', floor(userdatafixed/10));
            set(hDFGui.lPlot_YVar, 'Value', mod(userdatafixed,10));
        else
            set(hDFGui.lChoosePlot, 'Value', userdatafixed);
        end
        ChoosePlot();
    end
end
set(hDFGui.lChoosePlot, 'Value', 3);

function DeletePlots
h=findobj('Tag','Plot');
delete(h);

function ChoosePlot()
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
f=figure;
str = [' - '];
optionfields = fields(Options);
for field = optionfields'
    fchar = char(field);
    if strcmp(fchar, 'lChoosePlot') || strcmp(fchar, 'lPlot_XVar') || strcmp(fchar, 'lAdditionalPlots') || ...
            strcmp(fchar, 'lPlot_YVar') || strcmp(fchar, 'cPlotGrowingTracks') || strcmp(fchar, 'cLegend') || strcmp(fchar, 'cOnlySelected') ...
            || strcmp(fchar, 'lMethod_TrackValue') || strcmp(fchar, 'lMethod_TrackValueY') || strcmp(fchar, 'lSubsegment')
        continue
    end
    str = [str fchar '=' Options.(fchar).print ' | '];
end
uicontrol(f, 'Style', 'text', 'String',str(4:end), 'Units','norm', 'Position', [0.1 0.98 0.9 0.02]);
set(f,'WindowKeyPressFcn','fJKDynamicFilamentsGui(''Quicksave'');');
ChosenPlot = get(hDFGui.lChoosePlot, 'Value');
if ChosenPlot < 3
    XStr = Options.lPlot_XVar.print;
    YStr = Options.lPlot_YVar.print;
    XVar = Options.lPlot_XVar.val;
    YVar = Options.lPlot_YVar.val;
    if ChosenPlot == 1
        varnames = get(hDFGui.lPlot_XVar, 'String');
        [Options.ZVar,Options.ZOK] = listdlg('ListString', varnames, 'SelectionMode', 'single');
        if Options.ZOK
            Options.ZVarName = varnames{Options.ZVar};
        end
        set(f, 'Name',[XStr ' vs ' YStr str], 'Tag', 'Plot', ...
            'UserData', XVar*10+YVar);
        PrepareXYData(0 , Options);
    else
        Options.ZOK = 0;
        set(f, 'Name',['Events along ' XStr ' per ' YStr str], 'Tag', 'Plot', ...
            'UserData', 100+XVar*10+YVar);
        PrepareXYData(1 , Options);
    end
else
    plotstr = get(hDFGui.lChoosePlot, 'String');
    set(f, 'Name',[plotstr{ChosenPlot} str], 'Tag', 'Plot', 'UserData', ChosenPlot);
    switch ChosenPlot
        case 3
            if hDFGui.complicated
                EventPlot(Options.lGroup.val, Options.eRescueCutoff.val);
            end
        case 4
            BoxPlot(Options);
        case 5
            TrackXYPlot(Options);
        case 6
            DataPlot(hDFGui);
        case 7
            answer = questdlg('Format intensity into error function shape?', 'Option', 'Yes','No','Yes' );
            if strcmp(answer, 'Yes')
                has_err_fun_format = 1;
            else
                has_err_fun_format = 0;
            end
            FilamentEndPlot(hDFGui, has_err_fun_format);
        case 8
            AgainstOtherMTTracksPlot(Options);
        case 9
            IntensityVsDistWeightedVel(Options);
    end
end
set(gcf, 'Position', get(0,'Screensize')); 

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
for i=1:length(Tracks)
    Tracks(i).XEventEnd = Tracks(i).XEventEnd(xcolumn);
    Tracks(i).XEventStart = Tracks(i).XEventStart(xcolumn);
end
[Tracks, DelObjects] = SelectSubsegments(Tracks, Options, 'X');
Tracks(DelObjects) = [];
events(DelObjects) = [];
type(DelObjects) = [];
[Tracks, ~] = SelectSubsegments(Tracks, Options, 'Y');
if Options.ZOK
    for i=1:length(Tracks)
        Tracks(i).Z = Tracks(i).Data(:,Options.ZVar);
    end
    [Tracks, ~] = SelectSubsegments(Tracks, Options, 'Z');
end
Tracks = rmfield(Tracks, 'Data');
fJKplotframework(Tracks, type, isfrequencyplot, events, Options);

function [Tracks, DelObjects] = SelectSubsegments(Tracks, Options, field)
DelObjects = false(length(Tracks),1);
switch Options.lSubsegment.val
    case 2
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment
                Tracks(i).(field) = Tracks(i).(field)(1:Tracks(i).end_first_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 3
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).(field) = Tracks(i).(field)(Tracks(i).end_first_subsegment:Tracks(i).start_last_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 4
        for i=1:length(Tracks)
            if Tracks(i).start_last_subsegment
                Tracks(i).(field) = Tracks(i).(field)(Tracks(i).start_last_subsegment:end);
            else
                DelObjects(i) = 1;
            end
        end
    case 5
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).(field) = Tracks(i).(field)(1:Tracks(i).start_last_subsegment);
            else
                DelObjects(i) = 1;
            end
        end
    case 6
        for i=1:length(Tracks)
            if Tracks(i).end_first_subsegment && Tracks(i).start_last_subsegment
                Tracks(i).(field) = Tracks(i).(field)(Tracks(i).end_first_subsegment:end);
            else
                DelObjects(i) = 1;
            end
        end
    case 7
        for i=1:length(Tracks)
            if Tracks(i).minindex > 1 && Tracks(i).minindex < length(Tracks(i).(field))
                Tracks(i).(field) = Tracks(i).(field)(Tracks(i).minindex:end);
            else
                DelObjects(i) = 1;
            end
        end
end
for i=1:length(Tracks)
    if isempty(Tracks(i).(field))
        DelObjects(i) = 1;
    end
end


function [type, Tracks, event]=SetType(PlotGrowingTags) %PlotGrowingTags is needed because of the event plot
if PlotGrowingTags 
    plottag = 1;
else
    plottag = 4; %this is a code (see DF.SegmentFIESTAFils.m))
end
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
if ~isempty(strfind(Options.lPlot_XVar.print, 'Ase1')) || ~isempty(strfind(Options.lPlot_YVar.print, 'Ase1'))
    OnlyWithIntensity = 1;
else
    OnlyWithIntensity = 0;
end
if Options.lPlot_XVar.val > 6 || Options.lPlot_YVar.val > 6 
    OnlyWithCustomData = 1;
else
    OnlyWithCustomData = 0;
end
Tracks = getappdata(hDFGui.fig,'Tracks');
if Options.cOnlySelected.val
    Objects = getappdata(hDFGui.fig,'Objects');
    selected=get(hDFGui.lSelection,'Value');
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
    if hDFGui.mode == 2
        if floor(event(i))~=plottag || size(Tracks(i).Data, 1) < Options.eMinLength.val
            track_id(i)=0;
            continue
        end
        if Options.cPlotGrowingTracks.val == 1 && Tracks(i).Duration < Options.eMinDuration.val
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
    end
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
    if hDFGui.mode == 2
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
hDFGui=getappdata(0,'hDFGui');
months = {'JanFebMarAprMayJunJulAugSepOctNovDec'};
Objects = getappdata(hDFGui.fig,'Objects');
mode=get(hDFGui.lSortFilaments,'Value');
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
            order = fliplr(order);
        case 3
            return
    end
    Objects = Objects(order);
end
setappdata(hDFGui.fig,'Objects',Objects);
DF.updateOptions();

function EventPlot(group, cutoff)
subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.08], [0.08 0.08], [0.08 0.02]);
PlotGrowing=[1 0];
for i=1:2
    [type, Tracks, event]=SetType(PlotGrowing(i));
    uniquetypes=unique(type, 'stable');
    NEvents=zeros(length(uniquetypes),1);
    sumTime=zeros(length(uniquetypes),1);
    sumFrames=zeros(length(uniquetypes),1);
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
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','red');
                plot(typenum, Tracks(n).Data(end,2), 'Color','red', 'LineStyle', 'none', 'Marker','o');
            else
                text(typenum+0.1, double(Tracks(n).Data(end,2)), print_str, 'Color','black');
                plot(typenum, Tracks(n).Data(end,2), 'Color','black', 'LineStyle', 'none', 'Marker','o');
            end
            sumTime(typenum)=sumTime(typenum)+Tracks(n).Duration;
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    subplot(2,2,2*(i-1)+2)
    hold on
    fEvents = NEvents./sumTime;
    fError = sqrt(NEvents)./sumTime; %see https://www.bcube-dresden.de/wiki/Error_bars
    bar(fEvents,'stacked', 'r');
    h_error = errorbar(fEvents, fError, '.');
    for j=1:length(uniquetypes)
        if fEvents(j)
            text(j, fEvents(j)/2, {[num2str(fEvents(j), 2) ' per s'], ['N=' num2str(NEvents(j))], [num2str(sumTime(j)/60,'%1.1f') ' min']}, 'HorizontalAlignment', 'center', 'FontSize',16);
        else
            text(j, fEvents(j)/2, ['0 in ' num2str(sumTime(j)/60,'%1.1f') ' min'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize',16);
        end
    end
    set(gca,'XTick',1:length(uniquetypes), 'FontSize',18, 'LabelFontSizeMultiplier', 1.5,'xticklabel',uniquetypes, 'Ticklength', [0 0]);
    if (length(uniquetypes)>2&&group>1)||length(uniquetypes)>3
        set(gca,'XTickLabelRotation',15);
    end
    if isempty(strfind(uniquetypes{1}, '\downarrow'))
        ylabel('Catastrophe frequency [1/s]');
    else
        ylabel('Rescue frequency [1/s]');
    end
    legend(h_error, 'statistical uncertainty', 'Location', 'best');
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
if Options.lMethod_TrackValue.val == 7
    if strcmp(unit, 'nm/s')
        methodstr = 'linear fit';
    else
        methodstr = 'sum';
    end
end
if Options.cPlotGrowingTracks.val==1
    label=[title ' (' methodstr '. Only tracks > ' Options.eMinDuration.print ' evaluated)'  ' [' unit ']'];
else
    label=[title ' (' methodstr ')' ' [' unit ']'];
end


function AgainstOtherMTTracksPlot(Options)
button = fQuestDlg('Against which tracks of the same MT?','Which tracks?',...
    {'Previous Growing Track', 'Previous Shrinking Track', 'All Other Growing', 'All Other Shrinking'},'Previous Growing Track', 'noplacefig');
if strcmp(button,'Previous Growing Track')
    ChoseGrowTracks = 1;
    ChosePreviousTrack = 1;
elseif strcmp(button,'Previous Shrinking Track')
    ChoseGrowTracks = 0;
    ChosePreviousTrack = 1;
elseif strcmp(button,'All Other Growing')
    ChoseGrowTracks = 1;
    ChosePreviousTrack = 0;
elseif strcmp(button,'All Other Shrinking')
    ChoseGrowTracks = 0;
    ChosePreviousTrack = 0;
end
hold on
[type, AnalyzedTracks, ~]=SetType(Options.cPlotGrowingTracks.val);
if Options.cPlotGrowingTracks.val && ~ChoseGrowTracks
    [~, AnalyzedOtherTracks, ~]=SetType(0);
    labels = {'Track Value (Growing): ', 'Same MT Track(s) Mean Values (Shrinking): '};
elseif (Options.cPlotGrowingTracks.val && ChoseGrowTracks) || (~Options.cPlotGrowingTracks.val && ~ChoseGrowTracks)
    AnalyzedOtherTracks = AnalyzedTracks;
    if ChoseGrowTracks
        labels = {'Track Value (Growing): ', 'Same MT Track(s) Mean Values (Growing): '};
    else
        labels = {'Track Value (Shrinking): ', 'Same MT Track(s) Mean Values (Shrinking): '};
    end
elseif ~Options.cPlotGrowingTracks.val && ChoseGrowTracks
    [~, AnalyzedOtherTracks, ~]=SetType(1);
    labels = {'Track Value (Shrinking): ', 'Same MT Track(s) Mean Values (Growing): '};
end
[~, type_id, track_type_id] = unique(type);
[x_vec, ~] = DF.get_plot_vectors(Options, AnalyzedTracks, 1);
[~, other_y_vecs] = DF.get_plot_vectors(Options, AnalyzedOtherTracks, 2);
MT_indices = [AnalyzedOtherTracks.MTIndex];
track_indices = [AnalyzedOtherTracks.TrackIndex];
y_vec = nan(size(x_vec));
for m = 1:length(x_vec)
    related_tracks = find(MT_indices == AnalyzedTracks(m).MTIndex);
    if length(related_tracks) > 1
        current_track_track_id = find(track_indices == AnalyzedTracks(m).TrackIndex);
        if ChosePreviousTrack
            if isempty(current_track_track_id)
                try
                    previous_track_track_id = find(track_indices == AnalyzedTracks(m).TrackIndex-1);
                    previous_track_MT_id = find(related_tracks == previous_track_track_id);
                catch
%                     there is no track directly before the current track
%                     in AnalyzedOtherTracks, possibly because it was too
%                     short and was cut out
                    previous_track_MT_id = 0;
                end
            else
                previous_track_MT_id = find(related_tracks == current_track_track_id)-1;
            end
            if previous_track_MT_id
                related_tracks = related_tracks(previous_track_MT_id);
            else
                related_tracks = [];
            end
        else
            related_tracks = setxor(related_tracks, current_track_track_id);
        end
        same_MT_vecs = other_y_vecs(related_tracks);
        y_vec(m) = mean(same_MT_vecs);
    else
        y_vec(m) = NaN;
    end
end
fJKscatterboxplot(x_vec, y_vec, track_type_id', 0);
xlabel([labels{1} get_label(Options, 1)]);
ylabel([labels{2} get_label(Options, 0)]);
Legend = type(type_id);
legend(Legend{:});
hold off


function TrackXYPlot(Options)
hold on
[type, AnalyzedTracks, ~]=SetType(Options.cPlotGrowingTracks.val);
[~, type_id, track_type_id] = unique(type);
[x_vec, y_vec] = DF.get_plot_vectors(Options, AnalyzedTracks, 1:2);
fJKscatterboxplot(x_vec, y_vec, track_type_id', 0);
xlabel(get_label(Options, 1));
ylabel(get_label(Options, 0));
Legend = type(type_id);
legend(Legend{:});
hold off

function [middlex, middley, middlez] = histcounts2(plotx, ploty, plotz)
%HISTCOUNTS2D Summary of this function goes here
%   Detailed explanation goes here
hDFGui=getappdata(0,'hDFGui');
binwidth=str2double(get(hDFGui.eDistanceWeight, 'String'));
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


function FilamentEndPlot(hDFGui, has_err_fun_format)
Options = getappdata(hDFGui.fig,'Options');
Objects = getappdata(hDFGui.fig,'Objects');
answer = questdlg('Rhodamine/GFP?', 'Channel?', 'Rhodamine','GFP','Rhodamine' );
if strcmp(answer, 'GFP')
    kymo_field = 'pixelkymo_GFP';
else
    kymo_field = 'pixelkymo';
end
l = Objects(1).CustomData.(kymo_field).ScanOptions.help_get_tip_kymo.ExtensionLength;
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
        data = Objects(Tracks(n).MTIndex).CustomData.(kymo_field).Data{p};
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
[x_vec, ~] = DF.get_plot_vectors(Options, AnalyzedTracks, 1);
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
        plot(plot_x, type_datavec, '*', 'Color', [1,102,94]/255, 'MarkerSize', 25); %[217;95;2]/255
        text(j,nanmean(type_datavec),{num2str(median(type_datavec),3), ['N = ' num2str(length(type_datavec))]}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize',18);
    end
    set(gca,'XTickLabel','', 'FontSize',26, 'LabelFontSizeMultiplier', 1.5, 'XTickLabelMode','manual');
    hxt = get(gca, 'XTick');
    ypos = min(ylim) - diff(ylim)*0.05;
    newtext = text(hxt, ones(1, length(type_id))*ypos, type(type_id), 'HorizontalAlignment', 'center', 'FontSize',18);
    if (length(type_id)>2&&Options.lGroup.val>1)||length(type_id)>3
        set(newtext, 'rotation', 15);
    end
    h = findobj(b,'tag','Outliers');
    set(h,'Visible','off');
    ylabel(get_label(Options, 1));
end
hold off

function DataPlot(hDFGui)
Objects = getappdata(hDFGui.fig,'Objects');
Options = getappdata(hDFGui.fig,'Options');
hasvelocity=nan(length(Objects),1);
group=cell(length(Objects),1);
grouping=get(hDFGui.lGroup, 'Value');
for n = 1:length(Objects) 
    group{n} = Objects(n).Type;
    switch Options.lGroup.val
        case 1
            prepend = '';
        case 2
            splitstr = strsplit(Objects(n).File,'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}  ' \_ '];
            else
                prepend=[splitstr{2}  ' \_ '];
            end
        case 3
            splitstr = strsplit(Objects(n).File,'_');
            if length(splitstr{1})>3
                prepend=[splitstr{1}(7:8) ' \_ ' splitstr{2} ' \_ '];
            else
                prepend=[splitstr{2} ' \_ ' splitstr{1} ' \_ '];
            end
        case 4
            prepend = '';
            group{n} = 'everything';
    end
    group{n}=[prepend group{n}];
    hasvelocity(n) = ~all(isnan(Objects(n).Velocity(:,1)));
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