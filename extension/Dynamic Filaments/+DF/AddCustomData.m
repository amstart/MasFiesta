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
