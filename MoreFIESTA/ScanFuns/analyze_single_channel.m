function [ output_args ] = analyze_single_channel(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
global ScanOptions
if ~isfield(ScanOptions, 'ObjectChannel')
    input = inputdlg('Analyze objects in which channel?','Object Channel',1,{'1'});
    ScanOptions.ObjectChannel = str2double(input);
    input = inputdlg('Extract data from which channel? This channel will also be corrected','Channel',1,{'2'});
    ScanOptions.Channel = str2double(input);
end
load([PathName FileName]);
Filament = load([PathName FileName], 'Filament');
Filament = Filament.Filament;
Filament = Filament([Filament.Channel]==ScanOptions.ObjectChannel);
%% Helper Functions
for m = 1:length(Filament)
    Filament(m) = help_CorrectObject(Filament(m), PathName);
end
[Stack, ~, ~] = help_GetStack(PathName, Filament(1).File);
Stack = Stack{1};
[Filament] = help_get_tip_kymo(Stack, Filament);
%% save data
deletefields = setxor(fields(Filament), {'Custom'});
CroppedFilament = rmfield(Filament, deletefields);
intensities = cell(length(CroppedFilament),1);
for i = 1:length(CroppedFilament)
    intensities{i} = CroppedFilament(i).Custom.Intensity;
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