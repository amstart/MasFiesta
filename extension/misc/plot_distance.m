% answer = inputdlg('Look for Molecules in which radius?');
objects = Molecule;
% handle = progressdlg('String','Looking for close Molecules','Min',0,'Max',length(objects));
already = false(1, length(objects));
distancevec = [];
abort = false;
for i=length(Molecule)
    for j=length(Molecule)
        m1 = Molecule(i);
        m2 = Molecule(j);
        if m1.Channel~=m2.Channel
                p1 = objects(i).Results(1,3:4);
                p2 = objects(j).Results(1,3:4);
                distance = CalcDistance(p1,p2);
%             if distance < 600 %str2double(answer)
                distancevec = [distancevec distance];
                already(j) = true;
                objects(j).Name = [objects(i).Name(1:end-1) objects(j).File(8)];
%             end
        end
    end
%     progressdlg(i);
end
if ~abort
    Molecule = objects;
end
% gscatter();


% % answer = inputdlg('Look for Molecules in which radius?');
% objects = Molecule;
% % handle = progressdlg('String','Looking for close Molecules','Min',0,'Max',length(objects));
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
%     Molecule = objects;
% end
% % gscatter();