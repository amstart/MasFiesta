% global Molecule
% newset = Molecule;
% answer = inputdlg('By how many frames?');
% for i=1:length(Molecule)
%     if Molecule(i).Selected
%         Molecule(i).Results(:,1) = Molecule(i).Results(:,1)+str2double(answer{1});
%     end
% end
global Molecule;
objects=Molecule;
flushinframes = [17 2 127 5 20];
frames = zeros(length(objects),1);
names = cell(length(objects),1);
files = cell(length(objects),1);
id = zeros(length(objects),1);
for i=1:length(objects)
    frames(i) = objects(i).Results(1);
    names{i} = objects(i).Name;
    files{i} = objects(i).File;
    id(i) = i;
end
[uniques, type_id, track_type_id] = unique(files, 'stable');
normalizedframes = zeros(length(objects),1);
for i=1:length(objects)
    normalizedframes(i) = frames(i) - flushinframes(track_type_id(i));
end
histogram(normalizedframes)
ylabel('occurrences');
xlabel('first occurrence of patch (relative to first flushin frame)');
figure
hold on
histogram(normalizedframes(normalizedframes<50 & normalizedframes>0))
ylabel('occurrences');
xlabel('first occurrence of patch (relative to first flushin frame)');