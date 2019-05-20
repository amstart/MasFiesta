function updateOptions(varargin)
global DFDir
var_units = {'s', 'nm', 'nm/s', '1/nm', '', '1'};
var_names = {'time', 'location', 'velocity', 'Ase1 count', 'auto tags', 'frames'};
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
if ~isempty(Objects)
    Objects = Objects(1);
    if ~isempty(Objects.CustomData)
        for customfield = fields(Objects.CustomData)'
            if  ~isempty(Objects.CustomData.(customfield{1}).plot_options)
                var_units = {var_units{:} Objects.CustomData.(customfield{1}).plot_options{2,:}};
                var_names = {var_names{:} Objects.CustomData.(customfield{1}).plot_options{1,:}};
            end
        end
    end
end
set(hDFGui.lPlot_XVar, 'UserData', var_units ,'String', var_names, 'Value', min(length(var_names), get(hDFGui.lPlot_XVar, 'Value')));
set(hDFGui.lPlot_YVar, 'UserData', var_units ,'String', var_names, 'Value', min(length(var_names), get(hDFGui.lPlot_YVar, 'Value')));
children = get(hDFGui.pOptions, 'Children');
children = vertcat(children, get(hDFGui.pLoadOptions, 'Children'));
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
            Options.(tagname).print = strings{min(Options.(tagname).val, length(strings))};
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
setappdata(hDFGui.fig,'Options',Options);
if gcbo == hDFGui.bSaveOptions
    try
        [FileName, PathName] = uiputfile({'*.mat','MAT-File (*.mat)';},'Save Options' ,DFDir);
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
elseif gcbo == hDFGui.bDoPlot
    fJKDynamicFilamentsGui('ChoosePlot');
elseif gcbo == hDFGui.bUpdatePlots
    UpdatePlot(hDFGui);
elseif gcbo == hDFGui.lPlot_XVar
    DF.Draw(hDFGui);
elseif gcbo == hDFGui.lPlot_YVar
    DF.Draw(hDFGui);
elseif gcbo == hDFGui.lMethod_TrackValue
    DF.Draw(hDFGui);
elseif gcbo == hDFGui.lMethod_TrackValueY
    DF.Draw(hDFGui);
elseif gcbo == hDFGui.bSegment %bSegment button is pressed
    [Objects, Tracks] = hDFGui.Segment(Options);
    setappdata(hDFGui.fig,'Tracks', Tracks);
    setappdata(hDFGui.fig,'Objects',Objects);
end
DF.SetTable();