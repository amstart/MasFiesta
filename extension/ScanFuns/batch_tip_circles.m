function [ output_args ] = batch_tip_circles(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
global ScanOptions
%rmappdata(0, 'hMainGui');
ScanOptions.PixSize = 157; %is used as default if nothing else available
%%%%%%%%%%%%%%%%%%%parameters for helper functions%%%%%%%%%%%%%%
ScanOptions.help_get_tip_intensities.framesuntilmissingframe = 40; %set to number higher than number of frames if you have the same number of frames for the channels
ScanOptions.help_get_tip_intensities.method = 'get_pixelkymo';
ScanOptions.help_get_tip_intensities.AllFilaments = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.help_CorrectObject.AddDrift = 1;
ScanOptions.help_CorrectObject.RemoveColorCorrection = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.help_get_tip_points.max_points = 500;
ScanOptions.help_get_tip_points.GFP_frame_where = 0.4759;
if ~isfield(ScanOptions, 'ObjectChannel')
    input = inputdlg('Analyze objects in which channel?','Object Channel',1,{'1'});
    ScanOptions.ObjectChannel = str2double(input);
    input = inputdlg('Extract data from which channel?','Channel',1,{'2'});
    ScanOptions.Channel = str2double(input);
end
%% Load the Filament
Filament = load([PathName FileName]);
Filament = Filament.Filament;
frame_data = load([PathName 'shrinkingframes.mat']);
frame_data = frame_data.Data;
%% Helper Functions
% Reference = select_filaments(Filament, 3);
Filament = select_filaments(Filament, ScanOptions.ObjectChannel);
% Filament = help_extension_only(Filament, Reference);
Filament = help_CorrectObject(Filament, PathName);
% [Filament] = help_get_tip_points(Filament, ScanOptions);
[Stack, ~, ~] = help_GetStack(PathName, Filament(1).File);
Stack = Stack{1};
names = {Filament.Name};
for i=1:length(names)
    index = cellfun(@(x)strcmp(x, names{i}), frame_data(:,2));
    if any(index)
        shrinkingframes{i} = frame_data{index,1};
    else
        shrinkingframes{i} = nan;
    end
end
[Filament] = help_get_ref_frames_kymo(Filament, shrinkingframes);
[Filament] = help_get_tip_kymo(Stack, Filament);
%% save data
Data = cell(length(Filament),2);
for i = 1:length(Filament)
    Data{i,1} = Filament(i).Custom.CustomData;
    Data{i,2} = Filament(i).Name;
end
save([PathName ScanOptions.filename], 'Data', 'ScanOptions')


%how to calculate GFP_frame_where:
% rhotime = TimeInfo{1}(3:33)';
% GFPtime = TimeInfo{2}(2:32)';
% GFPtime_before = TimeInfo{2}(1:31)';
% timediff1 = zeros(20,1);
% timediff2 = zeros(20,1);
% for m = 1:20
%     timediff1(m) = (GFPtime(m)-rhotime(m))./1000;
%     timediff2(m) = abs((GFPtime_before(m)-rhotime(m))./1000);
% end
% totaltime = timediff1 + abs(timediff2);
% fraction = timediff1 ./ totaltime;
% GFP_frame_where = mean(fraction);