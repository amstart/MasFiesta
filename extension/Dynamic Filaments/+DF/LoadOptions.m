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
