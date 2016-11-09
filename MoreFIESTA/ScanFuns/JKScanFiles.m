%This script sets the options for the file scan and calls a function which
%scans through the link file you specify here. 
global CurrentDir
global ScanOptions
global supress_progressdlg
supress_progressdlg = 1;
%rmappdata(0, 'hMainGui');
ScanOptions.PixSize = 157; %is used as default if nothing else available
%%%%%%%%%%%%%%%%%%%parameters for helper functions%%%%%%%%%%%%%%
ScanOptions.help_get_tip_intensities.BlockHalf = 3; %only needed for mode "get_highest"
ScanOptions.help_get_tip_intensities.framesuntilmissingframe = 40; %set to number higher than number of frames if you have the same number of frames for the channels
ScanOptions.help_get_tip_intensities.MTend = 1; %1 = PosStart, 2 = PosEnd
ScanOptions.help_get_tip_intensities.method = 'get_highest';
ScanOptions.help_get_tip_intensities.AllFilaments = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.filename = [ScanOptions.help_get_tip_intensities.method '.mat'];
ScanOptions.ObjectChannel = 1;
ScanOptions.Channel = 2;
ScanOptions.ReplaceFileNamePattern{1} = 'red';
ScanOptions.ReplaceFileNamePattern{2} = 'green';
%% Do the work
try
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link',CurrentDir);
catch
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link');        
end
CurrentDir=PathName;     
fJKLoadLink(FileName, PathName, @analyze_single_channel) %any analyze_x function
supress_progressdlg = 0;