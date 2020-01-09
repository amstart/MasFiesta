function AddCustomData(varargin)
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
LoadedFromPath = {Objects.LoadedFromPath};
[unique_paths, ~, MT_index] = unique(LoadedFromPath, 'stable');
filename = inputdlg('Filename (without .mat)? You will find the data under Object.Custom.<filename>', 'Filename?', 1, {'pixelkymo_GFP_shifted'});
filename = filename{1};
if  ~isempty(strfind(filename, 'Expo_fit')) || ~isempty(strfind(filename, 'fit_run'))
    fun = @PrepareExpoData;
    read_fun = @ReadExpoData;
    plot_options = {'Amplitude', 'MT end', 'Sigma', 'PSF width', 'Bg1', 'Bg2', 'shift_bg', 'MSE';...
        '1', 'nm', 'nm', 'nm', '1/nm', '1/nm', 'nm', 'AU'};
elseif ~isempty(strfind(filename, 'fit'))
    fun = @PrepareFitData;
    read_fun = @ReadFitData;
    prefix = strrep(filename, 'pixelkymo_', '');
    prefix = strrep(prefix, '_fit', '');
    plot_options = {[prefix ' error function width'], [prefix ' error function displacement']; 'nm', 'nm'};
elseif ~isempty(strfind(filename, 'pixelkymo'))
    fun = @PrepareKymoData;
    read_fun = @intensityatfit;
    prefix = strrep(filename, 'pixelkymo_', '');
    plot_options = {[prefix ' intensity at fit']; 'AU'};
elseif ~isempty(strfind(filename, 'total_')) || ~isempty(strfind(filename, 'intensity_all'))
    fun = @(x) x;
    read_fun = @ReadtotalMAP;
    plot_options = {'total MAP count', 'average MAP count'; '1', '1/nm'};
elseif ~isempty(strfind(filename, 'tipandmiddleandallandycenter'))
    fun = @(x) x;
    read_fun = @ReadTipMiddleAllYPos;
    plot_options = {'Tip count', 'Density middle', 'Total count', 'Tip density', 'y center';...
        '1', '1/nm', '1', '1/nm', 'px'};
elseif ~isempty(strfind(filename, 'tipandmiddleandextension')) || ~isempty(strfind(filename, 'ext')) || ~isempty(strfind(filename, 'whole_MT'))
    fun = @(x) x;
    read_fun = @ReadTipMiddleExtension;
    plot_options = {'Tip count 7 pix', 'Middle count 5 pix', 'Extension count', 'Tip count 5 pix', 'x center', 'y center', 'Extension length';...
        '1', '1/nm', '1', '1/nm', 'px', 'px', 'nm'};
elseif ~isempty(strfind(filename, 'intensity_'))
    fun = @(x) x;
    read_fun = @ReadTFIData;
    plot_options = {'MAP count TIP', 'MAP count lattice'; '1/nm', '1/nm'};
else
    fun = @(x) x;
    read_fun = [];
    plot_options = {};
end
progressdlg('String','Appending Custom Data','Min',0,'Max',length(unique_paths));
for m=1:length(unique_paths)
        load_data = load([unique_paths{m} filename '.mat']);
        for n = find(MT_index == m)'
%             Objects(n).CustomData.(filename).ScanOptions = load_data.ScanOptions;
            for p=1:size(load_data.Data,1) %find microtubule data by name in second column
                if strcmp(Objects(n).Name, load_data.Data{p, 2})
                    Objects(n).CustomData.(filename).ScanOptions = load_data.ScanOptions;
                    custom_data = load_data.Data{p, 1};
                    Objects(n).CustomData.(filename).Data = fun(custom_data, Objects(n));
                    Objects(n).CustomData.(filename).read_fun = read_fun;
                    Objects(n).CustomData.(filename).plot_options = plot_options;
                end
            end
        end
    progressdlg(m);
end
setappdata(hDFGui.fig,'Objects',Objects);
DF.updateOptions();

function [matrix] = ReadExpoData(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 8, 8);
for m = 1:length(data)
    if length(data{m})>1
        matrix(m,:,:) = data{m}';
        matrix(m,[1 5 6],:) = matrix(m,[1 5 6],:)./Object.Custom.IntensityPerMAP;
        matrix(m,[2 3 4 7],:) = matrix(m,[2 3 4 7],:)*1000;
%         if matrix(m,7) > 5e8
%             matrix(m,:) = nan(1,7);
%         end
    end
end


function out = PrepareExpoData(fit_data, Object)
frames = Object.DynResults(:,1);
out = cell(length(frames),1);
for m = 1:length(fit_data)
    if ~iscell(fit_data{m}) || length(fit_data{m}{1}) == 1
        continue
    end
    out{frames-fit_data{m}{7}==0} = [fit_data{m}{1} fit_data{m}{2}'];
end


function [matrix] = ReadTipMiddleExtension(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 7);
% if ~isempty(strfind(Object.Comment, %maybe here it should check whether
% the MT can be used for this
for m = 1:length(data)
    if isnan(data{m}) 
        matrix(m,:) = nan;
    else
        matrix(m,:) = data{m};
    end
    if m>2 && isnan(matrix(m-1,1))
        matrix(m-1,1:4) = (matrix(m-2,1:4)+matrix(m,1:4))/2;
    end
end
matrix(:,[1:4]) = [[nan nan nan nan]; matrix(2:end,1:4)/(Object.Custom.IntensityPerMAP)];
% matrix(:,[2 4]) = [[nan nan]; matrix(2:end,[2 4])/(Object.Custom.IntensityPerMAP*(Object.PixelSize*5))];



function [matrix] = ReadTipMiddleAllYPos(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 4);
% if ~isempty(strfind(Object.Comment, %maybe here it should check whether
% the MT can be used for this
for m = 1:length(data)
    if isnan(data{m}) 
        matrix(m,1:5) = nan;
    else
        matrix(m,1:5) = data{m};
    end
    if m>2 && isnan(matrix(m-1,1))
        matrix(m-1,1:4) = (matrix(m-2,1:4)+matrix(m,1:4))/2;
    end
end
matrix(:,1:4) = [[nan nan]; matrix(2:end,[1 3])/(Object.Custom.IntensityPerMAP)];
% matrix(:,[2 4]) = [[nan nan]; matrix(2:end,[2 4])/(Object.Custom.IntensityPerMAP*(Object.PixelSize*5))];

function [matrix] = ReadtotalMAP(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 2);
% if ~isempty(strfind(Object.Comment, %maybe here it should check whether
% the MT can be used for this
for m = 1:length(data)
    if isnan(data{m}) 
        matrix(m,1:2) = nan;
    else
        matrix(m,1:2) = data{m};
    end
    if m>2 && isnan(matrix(m-1,1))
        matrix(m-1,1:2) = (matrix(m-2,1:2)+matrix(m,1:2))/2;
    end
end
matrix(:,1) = [nan; matrix(2:end,1)/(Object.Custom.IntensityPerMAP)];
matrix(:,2) = [nan; matrix(2:end,2)/(Object.Custom.IntensityPerMAP*Object.PixelSize)];

function [matrix] = ReadTFIData(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 2);
for m = 1:length(data)
    if isnan(data{m}) 
        matrix(m,1:2) = nan;
    else
        matrix(m,1:2) = data{m};
    end
    if m>2 && isnan(matrix(m-1,1))
        matrix(m-1,1:2) = (matrix(m-2,1:2)+matrix(m,1:2))/2;
    end
end
matrix(:,1) = [nan; matrix(2:end,1)/(Object.Custom.IntensityPerMAP*Object.PixelSize*5)];
matrix(:,2) = [nan; matrix(2:end,2)/(Object.Custom.IntensityPerMAP*Object.PixelSize*5)];

function vec = intensityatfit(Object, customfield, ~)
kymodata = Object.CustomData.(customfield{1}).Data;
vec = nan(length(kymodata), 2);
try
    locations = ReadFitData(Object, {[customfield{1} '_fit']}, [])/Object.PixelSize;
    locations = locations(:,1);
    locations = 6+[floor(locations)-1 ceil(locations)+1];
catch
    locations = vec;
end
for i=1:length(vec)
    if isnan(locations(i,1)) || length(kymodata{i})==1
        vec(i) = nan;
    else
        vec(i) = sum(kymodata{i}(locations(i,:)));
    end
end

function [matrix] = ReadFitData(Object, customfield, ~)
data = Object.CustomData.(customfield{1}).Data;
matrix = nan(length(data), 2);
for m = 1:length(data)
    if isstruct(data{m}) 
        if data{m}.w0 < 8 && abs(data{m}.x0) < 3.9  
            matrix(m,1) = data{m}.w0*Object.PixelSize;
            matrix(m,2) = data{m}.x0*Object.PixelSize;
        else
            matrix(m,1) = nan;
            matrix(m,2) = nan;
        end
    end
end

function fit_data = PrepareFitData(fit_data, ~)
for m = 1:length(fit_data)
    if ~isstruct(fit_data{m})
        fit_data{m} = nan;
        continue
    end
    tmp = fit_data{m}.gof;
    tmp.w0 = fit_data{m}.fitresult.w0;
    tmp.x0 = fit_data{m}.fitresult.x0;
%     tmp.p0 = fit_data{m}.fitresult.p0;
%     tmp.y0 = fit_data{m}.fitresult.y0;
    fit_data{m} = tmp;
end

function kymo_data = PrepareKymoData(kymo_data, Object)
%takes the background-subtracted sum per "cross section" of the kymograph line
for m = 1:length(kymo_data)
%     kymo_data{m} = max(kymo_data{m}, [], 1);
    kymo_data{m} = (nansum(double(kymo_data{m}), 1)-sum(~isnan(kymo_data{m}),1).*min(min(double(kymo_data{m}), [], 1)))/(Object.Custom.IntensityPerMAP*Object.PixelSize);
end
