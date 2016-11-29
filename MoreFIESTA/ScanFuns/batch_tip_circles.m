function [ output_args ] = batch_tip_circles(FileName, PathName)
%Gets Objects from a file, evaluates their intensities within the Stack
%they were tracked in and saves the output
%% Options
global ScanOptions
%rmappdata(0, 'hMainGui');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScanOptions.filename = ['tip_points' '.mat'];
ScanOptions.help_get_tip_points.max_points = 5;
ScanOptions.help_get_tip_points.GFP_frame_where = 0.4759;
%% Load the Kymograph data
Filament = load([PathName FileName]);
Filament = Filament.Filament;
Filament = Filament([Filament.Channel]==1);
%% Helper Functions
[testfil] = help_get_tip_points(Filament, ScanOptions);
%TODO: get finer points from first points until wanted distance (cumsum?)
% Data = [fit_results, kymodata(:,2)];
%% save data
% save([PathName ScanOptions.filename], 'Data', 'ScanOptions')


%how to calculate GFP_frame_where:
% rhotime = TimeInfo{1}(3:33)';
% GFPtime = TimeInfo{2}(2:32)';
% GFPtime_before = TimeInfo{2}(1:31)';
% timediff1 = zeros(20,1);
% timediff2 = zeros(20,1);
% for m = 1:20
%     timediff1(m) = (GFPtime(m)-rhotime(m))./1000;
%     timediff2(m) = abs((GFPtime_before(m)-rhotime(m))./1000);
% end
% totaltime = timediff1 + abs(timediff2);
% fraction = timediff1 ./ totaltime;
% GFP_frame_where = mean(fraction);