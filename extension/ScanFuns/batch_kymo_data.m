function [ output_args ] = batch_kymo_data(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
global ScanOptions
% try
%rmappdata(0, 'hMainGui');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.filename = ['fit_run6' '.mat'];
ScanOptions.help_fit_error_function.fit_session = @DoFitConvolutedExponential;
%% Load the Kymograph data
forFileName = load([PathName FileName]);
ScanOptions.File = forFileName.Filament(1).File;
file_data = load([PathName 'pixelkymo_GFP_shifted_fine.mat']);
frame_data = load([PathName 'shrinkingframes.mat']);
frame_data = frame_data.Data;
kymos = file_data.Data(:,1);
names = file_data.Data(:,2);
ScanOptions.kymo_options = file_data.ScanOptions;
onlyshrinking = 1;
for i=1:length(names)
    index = cellfun(@(x)strcmp(x, names{i}), frame_data(:,2));
    if any(index) && onlyshrinking
        shrinkingframes{i} = frame_data{index,1};
    else
        shrinkingframes{i} = [nan nan];
    end
end
%% Helper Functions
[fit_results] = help_fit_error_function(kymos, ScanOptions, shrinkingframes, names);
Data = [fit_results, names];
%% save data
save([PathName ScanOptions.filename], 'Data', 'ScanOptions')
% catch
%     'not working'
% end