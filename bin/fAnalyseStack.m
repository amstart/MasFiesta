function abort=fAnalyseStack(Stack,TimeInfo,Config,JobNr,Objects)
global logfile;
global error_events;
global DirCurrent;
global FiestaDir;
hMainGui=getappdata(0,'hMainGui'); 

error_events=[];
abort=0;

try
    params = setparams(Config);
catch
    params = 'connected objects';
end

if ~isempty(TimeInfo) && ~isempty(TimeInfo{1}) 
    params.creation_time_vector = (TimeInfo{1}-TimeInfo{1}(1))/1000;
    %check wether imaging was done during change of date 
    k = params.creation_time_vector<0;
    params.creation_time_vector(k) = params.creation_time_vector(k) + 24*60*60;
end

if strncmp(Config.TrackingServer,'local',5)
    num_cores = str2double(Config.TrackingServer(6:end));
    JobNr = -1;
end
if isinf(Config.LastFrame)
    Config.LastFrame = size(Stack{1},3);
end
if Config.LastFrame > size(Stack{1},3)
   Config.LastFrame = size(Stack{1},3);
end
if isempty(Objects)
    Objects = cell(1,size(Stack,2));
end
if ~isempty(strfind(Config.StackName,'.stk'))
    sName = strrep(Config.StackName, '.stk', '');
elseif ~isempty(strfind(Config.StackName,'.tif'))
    sName = strrep(Config.StackName, '.tif', '');
elseif ~isempty(strfind(Config.StackName,'.tiff'))
    sName = strrep(Config.StackName, '.tiff', '');
elseif ~isempty(strfind(Config.StackName,'.nd2'))
    sName = strrep(Config.StackName, '.nd2', '');
else
    sName = Config.StackName;
end
filename = [sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat']; %JochenK
try
    PathName=Config.Directory;
    movie=strsplit(sName, '_');
    if length(movie{1})>3 && length(movie)>1
        PathName = [PathName movie{2} filesep];
    else
        PathName = [PathName movie{1} filesep];
    end
    mkdir(PathName)
    fData=[PathName filename];
    save(fData,'Config');
catch
    PathName=DirCurrent;
    fData=[PathName filename];
    fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
    try
        save(fData,'Config');
    catch
        try
            underscores = strfind(a,'_');
            fData = [sName(1:underscores(1)) 'all(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
            save(fData,'Config');
        catch
            fData = ['all(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat'];
            save(fData,'Config');
        end
    end
end

filestr = [FiestaDir.AppData 'logfile.txt'];
logfile = fopen(filestr,'w');
if Config.FirstTFrame>0 && ~isnan(JobNr)
    FramesT = Config.LastFrame-Config.FirstTFrame+1;
    if JobNr>0
        params.display = 0;
        dirStatus = [DirCurrent 'Queue' filesep 'Job' int2str(JobNr) filesep 'Status' filesep];
        TimeT = clock; %#ok<NASGU>
        save([DirCurrent 'Queue' filesep 'Job' int2str(JobNr) filesep 'FiestaStatus.mat'],'TimeT','FramesT','-append');
        [y,x,z] = size(Stack{1});
        nStack = length(Stack);
        for n = nStack:-1:1
            Stack(n,1:z) = mat2cell(Stack{n},y,x,ones(1,z));
        end
        try
            parfor n=Config.FirstTFrame:Config.LastFrame
                Objects{n}=ScanImage(cat(3,Stack{:,n}),params,n);
                fSave(dirStatus,n);
            end
        catch ME
            save(fData,'-append','Objects','ME');
            return;
        end
    elseif JobNr==-1
        if ~isempty(gcp)
            delete(gcp);
        end
        parpool(num_cores);
        params.display = 0;
        dirStatus = [FiestaDir.AppData 'fiestastatus' filesep];  
        [y,x,z] = size(Stack{1});
        nStack = length(Stack);
        for n = nStack:-1:1
            Stack(n,1:z) = mat2cell(Stack{n},y,x,ones(1,z));
        end
        parallelprogressdlg('String',['Tracking on ' num2str(num_cores) ' cores'],'Max',Config.LastFrame-Config.FirstTFrame+1,'Parent',hMainGui.fig,'Directory',FiestaDir.AppData);
        try
            parfor n=Config.FirstTFrame:Config.LastFrame
                Objects{n}=ScanImage(cat(3,Stack{:,n}),params,n);
                fSave(dirStatus,n);
            end
        catch ME
            save(fData,'-append','Objects','ME');
            return;
        end  
        parallelprogressdlg('close');
        delete(gcp);
    else
        h=progressdlg('String',sprintf('Tracking - Frame: %d',Config.FirstTFrame),'Min',Config.FirstTFrame-1,'Max',Config.LastFrame,'Cancel','on','Parent',hMainGui.fig);
        for n=Config.FirstTFrame:Config.LastFrame
            Log(sprintf('Analysing frame %d',n),params);
            try
                Objects{n}=ScanImage(fGetStackFrame(Stack,n),params,n);
            catch ME
                save(fData,'-append','Objects','ME');
                return;
            end
            if params.dynamicfil && ~isempty(Objects{n})
                bw_region(:,:,2:end) = bw_region(:,:,1:end-1);
                bw_region(:,:,1) = 0;
                [y,x] = size(params.bw_region);
                for m = 1:length(Objects{n}.data)
                    if Objects{n}.length(1,m)~=0
                        X = round(Objects{n}.data{m}(:,1)/params.scale);
                        Y = round(Objects{n}.data{m}(:,2)/params.scale);
                        k = X<1 | X>x | Y<1 | Y>y;
                        X(k) = [];
                        Y(k) = [];
                        idx = Y + (X - 1).*y;
                        bw_region(idx) = 1;
                    end
                end
                SE = strel('disk', ceil(params.fwhm_estimate/2/params.scale) , 4);
                bw_region(:,:,1) = imdilate(bw_region(:,:,1),SE);
                params.bw_region = orig_region | sum(bw_region,3)>4;
            end
            if Config.FirstCFrame>0
                if ~isempty(Objects{n})
                    s=sprintf('Tracking - Frame: %d - Objects found: %d',n+1,length(Objects{n}.center_x));
                else
                    s=sprintf('Tracking - Frame: %d - Objects found: %d',n+1,0);
                end
                if isempty(h)
                    abort=1;
                    save(fData,'-append','Objects');
                    return
                end
                h=progressdlg(n,s);
            end
            
        end
        progressdlg('close');
    end
end
fclose(logfile);
disp(Config.StackName)
disp(error_events)
try
    save(fData,'-append','Objects');
catch
    filename = [sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat']; %JochenK
    PathName=DirCurrent;
    fData=[PathName filename];
    fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
    save(fData,'Objects','Config');
end
if ~isempty(Objects) && Config.ConnectMol.NumberVerification>0 && Config.ConnectFil.NumberVerification>0
    [Filament, Molecule] = fConnectObjects(Objects, Config, JobNr, Stack);
    try
        save(fData,'-append','Molecule','Filament');
    catch ME
        filename = [sName '(' datestr(clock,'yyyymmddTHHMMSSFFF') ').mat']; %JochenK
        PathName=DirCurrent;
        fData=[PathName filename];
        fMsgDlg(['Directory not accessible - File saved in FIESTA directory: ' DirCurrent],'warn');
        save(fData,'Molecule','Filament','Objects','Config');
    end
    try % JochenK
        fMenuData('LoadTracks', filename, PathName);
    catch
    end
    clear Molecule Filament Objects Config;
end

function fSave(dirStatus,frame)
fname = [dirStatus 'frame' int2str(frame) '.mat'];
save(fname,'frame');

function params = setparams(Config)
params.bw_region = Config.Region;
params.dynamicfil = 0;
if isfield(Config,'DynamicFil')
    params.dynamicfil = Config.DynamicFil;
    if Config.DynamicFil
        [y,x] = size(params.bw_region);
        bw_region = zeros(y,x,10);
        orig_region = params.bw_region;
    end
end
if isfield(Config,'TformChannel')
    params.transform = Config.TformChannel;
end

params.bead_model=Config.Model;
params.max_beads_per_region=Config.MaxFunc;
params.scale=Config.PixSize;
params.ridge_model = 'quadratic';

params.find_molecules=1;
params.find_beads=1;

if Config.OnlyTrackMol==1
    params.find_molecules=0;
end
if Config.OnlyTrackFil==1
    params.find_beads=0;
end
params.include_data = Config.OnlyTrack.IncludeData;
params.area_threshold=Config.Threshold.Area;
params.height_threshold=Config.Threshold.Height;   
params.fwhm_estimate=Config.Threshold.FWHM;
if isempty(Config.BorderMargin)
    params.border_margin = 2 * Config.Threshold.FWHM / params.scale / (2*sqrt(2*log(2)));
else
    params.border_margin = Config.BorderMargin;
end

if isempty(Config.ReduceFitBox)
    params.reduce_fit_box = 1;
else
    params.reduce_fit_box = Config.ReduceFitBox;
end

params.focus_correction = Config.FilFocus;
params.min_cod=Config.Threshold.Fit;
params.threshold = Config.Threshold.Value;
if length(Config.Threshold.Filter)==1
    [params.binary_image_processing,params.background_filter] = strtok(Config.Threshold.Filter{1},'+');
else
    params.binary_image_processing = [];
    params.background_filter=Config.Threshold.Filter;
end
params.display = 1;

params.options = optimset( 'Display', 'off','UseParallel','never');
params.options.MaxFunEvals = []; 
params.options.MaxIter = [];
params.options.TolFun = [];
params.options.TolX = [];
