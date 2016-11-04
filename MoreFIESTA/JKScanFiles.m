global CurrentDir
global ScanOptions
rmappdata(0, 'hMainGui');
input = inputdlg('Pixelsize?','Pixelsize',1,{'157'});
ScanOptions.PixSize = str2double(input);
input = inputdlg('Analyze objects in which channel?','Object Channel',1,{'1'});
ScanOptions.ObjectChannel = str2double(input);
input = inputdlg('Extract data from which channel? This channel will also be corrected','Channel',1,{'2'});
ScanOptions.Channel = str2double(input);
if ScanOptions.Channel ~= ScanOptions.ObjectChannel
     ScanOptions.ReplaceFileNamePattern = fInputDlg({'Fix the string in Object.File field to find the correct stack: replace','with'},{'red', 'green'}, 'noplacefig');
end
button = fQuestDlg('What should be corrected?','What?',{'Color (loads ''offset.mat'')','Drift (loads ''drift.mat'')', 'Both'},'Both', 'noplacefig');
if strcmp(button,'Color (loads ''offset.mat'')')
    ScanOptions.CorrectColor = 0;
    ScanOptions.CorrectDrift = 0;
elseif strcmp(button,'Drift (loads ''drift.mat'')')
    ScanOptions.CorrectColor = 0;
    ScanOptions.CorrectDrift = 1;
elseif strcmp(button,'Both')
    ScanOptions.CorrectColor = 1;
    ScanOptions.CorrectDrift = 1;
end
button = fQuestDlg('Which interpolation method should be used?','Choose Interpolation Method',{'Nearest(fast)','Linear(slow)'},'Nearest(fast)', 'noplacefig');
if strcmp(button,'Nearest(fast)')
    ScanOptions.linear = 0;
elseif strcmp(button,'Linear(slow)')
    ScanOptions.linear = 1;
end
try
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link',CurrentDir);
catch
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link');        
end
CurrentDir=PathName;     
fJKLoadLink(FileName, PathName, @get_highest_tip_intensities)