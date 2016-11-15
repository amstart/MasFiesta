function [ Filament ] = help_CorrectObject(Filament, PathName)
%CORRECTSTACK Corrects one channel in a stack, loading the Drift and the
%offset map from files within the same folder as the File from which the
%Objects were loaded
global ScanOptions
if ~isfield(ScanOptions, 'help_CorrectObject') || ~isfield(ScanOptions.help_CorrectObject, 'CorrectColor')
    button = fQuestDlg('What should be corrected?','What?',{'Nothing', 'Color (loads ''offset.mat'')','Drift (loads ''drift.mat'')', 'Both'},'Both', 'noplacefig');
    if strcmp(button,'Nothing')
        ScanOptions.help_CorrectObject.CorrectColor = 0;
        ScanOptions.help_CorrectObject.CorrectDrift = 0;
    elseif strcmp(button,'Color (loads ''offset.mat'')')
        ScanOptions.help_CorrectObject.CorrectColor = 1;
        ScanOptions.help_CorrectObject.CorrectDrift = 0;
    elseif strcmp(button,'Drift (loads ''drift.mat'')')
        ScanOptions.help_CorrectObject.CorrectColor = 0;
        ScanOptions.help_CorrectObject.CorrectDrift = 1;
    elseif strcmp(button,'Both')
        ScanOptions.help_CorrectObject.CorrectColor = 1;
        ScanOptions.help_CorrectObject.CorrectDrift = 1;
    end
end
if ScanOptions.help_CorrectObject.CorrectColor
    for offsetfilename = {'OffSet.mat', 'Offset.mat', 'offset.mat', 'offSet.mat'}
        try
            OffsetMap = load([PathName offsetfilename{1}]);
            break
        catch
        end
    end
    TformChannel = OffsetMap.OffsetMap(ScanOptions.Channel-1).T;
else
    TformChannel = [1 0 0;0 1 0;0 0 1];
end
if ScanOptions.help_CorrectObject.CorrectDrift
    try
        Drift = load([PathName 'Drift.mat']);
    catch
        Drift = load([PathName 'drift.mat']);
    end
    Drift = Drift.Drift{ScanOptions.Channel};
else
    Drift = [];
end
%% Do work
Filament = fCalcDrift(Filament, Drift, 0, 'noOrientationCorrection');