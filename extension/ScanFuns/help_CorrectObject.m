function [ Object ] = help_CorrectObject(Object, PathName)
%CORRECTSTACK Removes Drift and color correction from objects
global ScanOptions
if ~isfield(ScanOptions, 'help_CorrectObject') || ~isfield(ScanOptions.help_CorrectObject, 'RemoveColorCorrection')
    button = fQuestDlg('What should be corrected? Drift is removed first, then Objects are color transformed from channel 1 into another',...
        'What?',{'Nothing', 'Color (loads ''offset.mat'')','Drift (loads ''drift.mat'')', 'Both'},'Both', 'noplacefig');
    if strcmp(button,'Nothing')
        ScanOptions.help_CorrectObject.RemoveColorCorrection = 0;
        ScanOptions.help_CorrectObject.AddDrift = 0;
    elseif strcmp(button,'Color (loads ''offset.mat'')')
        ScanOptions.help_CorrectObject.RemoveColorCorrection = 1;
        ScanOptions.help_CorrectObject.AddDrift = 0;
    elseif strcmp(button,'Drift (loads ''drift.mat'')')
        ScanOptions.help_CorrectObject.RemoveColorCorrection = 0;
        ScanOptions.help_CorrectObject.AddDrift = 1;
    elseif strcmp(button,'Both')
        ScanOptions.help_CorrectObject.RemoveColorCorrection = 1;
        ScanOptions.help_CorrectObject.AddDrift = 1;
    end
end
if ScanOptions.help_CorrectObject.AddDrift
    try
        Drift = load([PathName 'Drift.mat']);
    catch
        Drift = load([PathName 'drift.mat']);
    end
    Drift = Drift.Drift{ScanOptions.ObjectChannel};
    for m = 1:length(Object)
        Object(m) = fCalcDrift(Object(m), Drift, 0, 'noOrientationCorrection');
    end
end
if ScanOptions.help_CorrectObject.RemoveColorCorrection
    for offsetfilename = {'OffSet.mat', 'Offset.mat', 'offset.mat', 'offSet.mat'}
        try
            OffsetMap = load([PathName offsetfilename{1}]);
        catch
        end
    end
    TformChannel = OffsetMap.OffsetMap(ScanOptions.Channel-1).T;
    TformChannel(3,3) = 0;
    mode = 1;
    for m = 1:length(Object)
        Object(m).Channel = ScanOptions.Channel;
        Object(m).TformMat = TformChannel;
        Object(m) = fTransformCoord(Object(m),mode,1);
        Object(m).Channel = 1;
    end
end