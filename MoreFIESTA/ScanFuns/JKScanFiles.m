%This script sets the options for the file scan and calls a function which
%scans through the link file you specify here. 
%% Do the work
global ScanOptions
try
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link',ScanOptions.LinkFolder);
catch
    [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Link');        
end
ScanOptions.LinkFolder=PathName;     
fJKLoadLink(FileName, PathName, @batch_rename) %any analyze_x function

% Z:\Data\Jochen\16.10.10\4\4_dynamics.mat
% Subscript indices must either be real positive integers or logicals.
% Error in help_get_tip_kymo>get_pixelkymo (line 72)
% dis = id-d(idx);
% Error in help_get_tip_kymo (line 47)
%             Filament(m).Custom.CustomData{n} = fun(I, Filament(m), n,
%             ScanOptions.help_get_tip_kymo.ScanSize,
%             ScanOptions.help_get_tip_kymo.ExtensionLength);
% Error in analyze_single_channel (line 42)
% [Filament] = help_get_tip_kymo(Stack, Filament);
% Error in fJKLoadLink (line 33)
%     fun(FileName, PathName);
% Error in JKScanFiles (line 11)
% fJKLoadLink(FileName, PathName, @analyze_single_channel) %any analyze_x function 