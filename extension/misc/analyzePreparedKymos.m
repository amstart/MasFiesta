folder = 'Y:\Jochen\180516_salt_samechan\006_frame118to008\';
nMT = 14;
t = [118*5:5:214*5 nan 216*5+190:5:448*5+190]./60;
flushins = [1 107 230 319];
labels = {'33nM Tau in 50mM', '33nM Tau in 75mM', '33nM Tau in 100mM', '0nM Tau in 100mM'};
labelx = 'time after flushing in 33nM Tau-mCherry in 50mM KCl [min]';
pixsize = 65;

% folder = 'Y:\Valerie\Valerie\20180424_SIMSTORM_multipleflushinout\008\';
% nMT = 7;
% t = [1:2174]./60;
% flushins = [1 8 519 1097 1456];
% labels = {'29nM Tau in 75mM', '29nM Tau in 75mM', '29nM Tau in 75mM', '59nM Tau in 75mM', '0nM Tau in 75mM'};
% labelx = 'time';
% pixsize = 65;

backgroundkymo = double(imread([folder 'backgroundkymo.tif']));
bg = cell(1,nMT);
for i = 1:nMT
    bg{i} = double(imread([folder 'prepared\' num2str(i) 'n.tif']));
end
patchkymos = cell(1,nMT);
for i = 1:nMT
    filename = [folder 'prepared\' num2str(i) 'p.tif'];
    try
        if exist(filename,'file')
            patchkymos{i} = double(imread(filename));
        else
            patchkymos{i} = double(imread([folder 'prepared\' num2str(i) 'pc.tif']));
        end
    catch
    patchkymos{i} = nan(length(t),1);
    end
end
analyzePatchKymos(patchkymos, bg, backgroundkymo, t, flushins, labels, labelx, pixsize);