folder = 'Y:\Jochen\180516_salt_samechan\006_frame118to008\';
nMT = 14;
patchappearin = 3;
day = '180516';
t = [118*5:5:214*5 nan 216*5+190:5:448*5+190]./60;
flushins = [1 107 230 319];
labels = {'33nM Tau in 50mM', '33nM Tau in 75mM', '33nM Tau in 100mM', '0nM Tau in 100mM'};
labelx = 'time after flushing in 33nM Tau-mCherry in 50mM KCl [min]';


% folder = 'Y:\Valerie\Valerie\20180424_SIMSTORM_multipleflushinout\008\';
% nMT = 7;
% patchappearin = 7;
% day = '180424';
% t = [1:2174]./60;
% flushins = [1 8 519 1097 1456];
% labels = {'29nM Tau in 75mM', '29nM Tau in 75mM', '29nM Tau in 75mM', '59nM Tau in 75mM', '0nM Tau in 75mM'};
% labelx = 'time';

threshfile = xlsread([folder 'wherebgwherepatch.xlsx']);
backgroundkymo = double(imread([folder 'backgroundkymo.tif']));
kymos = cell(1,nMT);
for i = 1:nMT
    kymos{i} = double(imread([folder num2str(i) '.tif']));
end
[patchkymos, bg] = definePatchBorders(kymos, threshfile, patchappearin, day);
analyzePatchKymos(patchkymos, bg, backgroundkymo, t, flushins, labels, labelx);
for i = 1:nMT
    imwrite(patchkymos{i}, [folder 'jpg/' num2str(i) '_thresholded.jpg']);
end