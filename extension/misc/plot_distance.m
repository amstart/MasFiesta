% answer = inputdlg('Look for objectss in which radius?');
objects = Molecule;
% handle = progressdlg('String','Looking for close objectss','Min',0,'Max',length(objects));
delete = false(length(objects),1);
flushinframes = [17 2 127 5 20];
for i = 1:length(objects)
    if ~isempty(strfind(objects(i).Name, 'p'))
        delete(i)= true;
    end
    correctmovingMT = [0 0];
    switch objects(i).Name
        case '3f_1'
            correctmovingMT = [950 1020];
        case '2b_1'
            correctmovingMT = [6780 2250];
    end
    objects(i).Results(1,3:4) = objects(i).Results(1,3:4) + correctmovingMT;
    objects(i).Frame = objects(i).Results(1,1) - flushinframes(objects(i).Channel);
end
objects(delete) = [];
todo = true(length(objects));
datamat = [];
abort = false;
for i=1:length(objects)
    for j=1:length(objects)
        m1 = objects(i);
        m2 = objects(j);
        flushs = [m1.Channel m2.Channel];
        if diff(flushs) && todo(j,i)
                p1 = m1.Results(1,3:4);
                p2 = m2.Results(1,3:4);
                distance = CalcDistance(p1,p2);
                todo(i,j) = false;
                if distance < 1000 %str2double(answer)
                    datamat = vertcat(datamat, [i j distance flushs p1 p2]);
                    %delete connections of i/j to other molecules in same
                    %movie as j/i which are longer than current:
                    competition = {find(datamat(:,5) == flushs(2) & datamat(:,1)==i), find(datamat(:,4) == flushs(1) & datamat(:,2)==j)};
                    for k = 1:2
                        [~,id] = min(datamat(competition{k},3));
                        competition{k}(id) = [];
                    end
                    datamat(union(competition{1}, competition{2}),:) = [];
%                     datamat( & datamat(:,3)>distance),:) = [];
                end
        end
    end
end
% figure
startpoints = setdiff(datamat(:,1),datamat(:,2));
mainmat = [datamat nan(size(datamat,1),1)];
altermat = [];
subtractedrows = [];
for i = startpoints' %subtract coordinates of the starting point from each chain of patch occurrences
    in_rows = find(datamat(:,1)==i);
    all_rows = in_rows;
    connected_to = unique(datamat(in_rows,2));
    for j = 1:5-datamat(in_rows(1), 4) %generate chains of occurrences
        indirectly_in_rows = [];
        for k = 1:length(connected_to)
            indirectly_in_rows = [indirectly_in_rows; find(ismember(datamat(:,1),connected_to(k)))];
        end
        all_rows = union(indirectly_in_rows, all_rows);
        connected_to = unique(datamat(indirectly_in_rows,2));
    end
    to_subtract = repmat(datamat(in_rows(1), 6:7), 1,2);
    first_timers = setdiff(all_rows, subtractedrows);
    mainmat(first_timers,10) = deal(i);
    subtractedrows = [subtractedrows; first_timers];
    mainmat(first_timers,6:9) = mainmat(first_timers,6:9) - repmat(to_subtract, length(first_timers), 1);
    second_timers = setdiff(all_rows, first_timers);
    altermat = vertcat(altermat, [datamat(second_timers, 1:5) datamat(second_timers, 6:9)...
        - repmat(to_subtract, length(second_timers), 1) repmat(i,length(second_timers), 1) ]);
end
plotmat = [mainmat; altermat];
delete = false(size(plotmat,1),1);
for i = 1:size(plotmat,1)
    if diff(plotmat(i,4:5))>1 && i>1
        if plotmat(i,1)==plotmat(i-1,1) && max(ismember(plotmat(:,1:2), [plotmat(i-1,2) plotmat(i,2)], 'rows'))
            delete(i)=true;
        end
    end
end
plotmat(delete,:)=[];
selection = false(length(objects), 3);
edges = [-20 0 10 20 30 40 50 100 150 200 250 300 350 400 450 500];
edgesmid=edges(1:end-1)+diff(edges)/2;
allframes = [objects.Frame];
allchannels = [objects.Channel];
[~,ia,~] = unique(plotmat(:,2));
selection(:, 1) = allchannels==1; %patches in flush 1
selection(ia, 3) = true; %reappearing patches
selection(:, 2) = ~selection(:, 1) & ~selection(:, 3);
N = zeros(1,length(edgesmid));
for i = 1:3
    [N(i,:),edges,bin] = histcounts(allframes(selection(:,i)), edges);
end
figure(1)
bar(edgesmid, N', 'Stacked')
legend('in flush 1', 'seen first time', 'reappearing')

% interest = 21;
% figure
% hold on
% specificplotmat = [[interest interest 0 0]; plotmat(plotmat(:,10)==interest,[1 2 8 9])];
% plot(specificplotmat(:,3), specificplotmat(:,4));
% specificplotmat = [[0 0]; plotmat(plotmat(:,10)==50,8:9)];
% plot(specificplotmat(:,1), specificplotmat(:,2));
% % answer = inputdlg('Look for objectss in which radius?');
% objects = objects;
% % handle = progressdlg('String','Looking for close objectss','Min',0,'Max',length(objects));
% already = false(1, length(objects));
% distancevec = [];
% abort = false;
% selected = [objects.Selected];
% for i=find(selected)
%     for j=find(selected)
%         if i~=j
%             if strcmp(objects(i).File, objects(j).File)
%                 msgbox('same movie');
%                 abort = true;
%                 break
%             end
%             if ~isempty(strfind(objects(i).Name, '_'))
%                 p1 = objects(i).Results(1,3:4);
%                 p2 = objects(j).Results(1,3:4);
%                 distance = CalcDistance(p1,p2);
% %             if distance < 600 %str2double(answer)
%                 distancevec = [distancevec distance];
%                 already(j) = true;
%                 objects(j).Name = [objects(i).Name(1:end-1) objects(j).File(8)];
% %             end
%             end
%         end
%     end
% %     progressdlg(i);
% end
% if ~abort
%     objects = objects;
% end
% % gscatter();