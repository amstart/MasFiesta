function [ output_args ] = analyze_single_channel(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
global ScanOptions
%rmappdata(0, 'hMainGui');
ScanOptions.PixSize = 157; %is used as default if nothing else available
%%%%%%%%%%%%%%%%%%%parameters for helper functions%%%%%%%%%%%%%%
ScanOptions.help_get_tip_intensities.BlockHalf = 3; %only needed for mode "get_highest"
ScanOptions.help_get_tip_intensities.framesuntilmissingframe = 40; %set to number higher than number of frames if you have the same number of frames for the channels
ScanOptions.help_get_tip_intensities.MTend = 1; %1 = PosStart, 2 = PosEnd
ScanOptions.help_get_tip_intensities.method = 'get_full_intensities_1_clip';
ScanOptions.help_get_tip_intensities.AllFilaments = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.help_get_tip_kymo.framesuntilmissingframe = 0; %set to number higher than number of frames if you have the same number of frames for the channels
ScanOptions.help_get_tip_kymo.method = 'get_pixelkymo';
ScanOptions.help_get_tip_kymo.AllFilaments = 1;
ScanOptions.help_get_tip_kymo.ScanSize = 3;
ScanOptions.help_get_tip_kymo.ExtensionLength = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.help_CorrectObject.AddDrift = 1;
ScanOptions.help_CorrectObject.RemoveColorCorrection = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.filename = [ScanOptions.help_get_tip_kymo.method '.mat'];
ScanOptions.ReplaceFileNamePattern{1} = 'red';
ScanOptions.ReplaceFileNamePattern{2} = 'red';
if ~isfield(ScanOptions, 'ObjectChannel')
    input = inputdlg('Analyze objects in which channel?','Object Channel',1,{'1'});
    ScanOptions.ObjectChannel = str2double(input);
    input = inputdlg('Extract data from which channel?','Channel',1,{'2'});
    ScanOptions.Channel = str2double(input);
end
%% Load the Filament
load([PathName FileName]);
Filament = load([PathName FileName], 'Filament');
Filament = Filament.Filament;
Filament = Filament([Filament.Channel]==ScanOptions.ObjectChannel);
%% Helper Functions
Filament = help_CorrectObject(Filament, PathName);
[Stack, ~, ~] = help_GetStack(PathName, Filament(1).File);
Stack = Stack{1};
[Filament] = help_get_tip_kymo(Stack, Filament);
%% save data
deletefields = setxor(fields(Filament), {'Custom'});
CroppedFilament = rmfield(Filament, deletefields);
intensities = cell(length(CroppedFilament),1);
for i = 1:length(CroppedFilament)
    intensities{i} = CroppedFilament(i).Custom.CustomData;
end
save([PathName ScanOptions.filename], 'intensities', 'ScanOptions')
%%
% %% Helper Functions
% [Stack, ~, PixSize] = help_GetStack(PathName, Filament(1).File);
% Stack = Stack{1};
% if isempty(PixSize)
%     if ~isfield(ScanOptions, 'PixSize')
%         input = inputdlg('Pixel Size?','Pixel Size',1,{'157'});
%         ScanOptions.PixSize = str2double(input);
%     end
%     PixSize = ScanOptions.PixSize;
% end
% if ~isfield(ScanOptions, 'help_CorrectStack') || ScanOptions.help_CorrectStack.CorrectColor || ScanOptions.help_CorrectStack.CorrectDrift
%     [ Stack ] = help_CorrectStack(Stack, PathName, PixSize);
% end
% [Filament] = help_get_full_intensities(Stack, Filament);