function [ output_args ] = batch_kymo_data(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
global ScanOptions
%rmappdata(0, 'hMainGui');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.filename = ['pixelkymo_fit' '.mat'];
ScanOptions.help_fit_error_function.fit_session = @FitErf;
%% Load the Kymograph data
file_data = load([PathName 'pixelkymo.mat']);
kymodata = file_data.data;
ScanOptions.kymo_options = file_data.ScanOptions;
%% Helper Functions
[fit_results] = help_fit_error_function(kymodata(:,1), ScanOptions);
Data = [fit_results, kymodata(:,2)];
%% save data
save([PathName ScanOptions.filename], 'Data', 'ScanOptions')