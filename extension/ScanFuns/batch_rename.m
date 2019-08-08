function [ output_args ] = batch_rename(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
try
% load([PathName 'pixelkymo_fit.mat']);
% delete([PathName 'pixelkymo_fit_backup.mat']);
movefile([PathName 'tmc.mat'], [PathName 'extension.mat'])
%% Load the Filament
% Filament = load([PathName FileName]);
% Filament = Filament.Filament;
% Filament = Filament([Filament.Channel]==1);
% old_data = load([PathName 'pixelkymo_fit_backup.mat']);
% Data = cell(length(Filament), 2);
% Data(:,1) = old_data.fit_results;
% for m =1:length(Filament)
%     Data(m,2) = {Filament(m).Name};
% end
% ScanOptions = old_data.ScanOptions;
% save([PathName 'pixelkymo_fit.mat'], 'Data', 'ScanOptions')
catch
    'not found'
end