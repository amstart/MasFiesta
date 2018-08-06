function SetTable()
hDFGui = getappdata(0,'hDFGui');
Objects = getappdata(hDFGui.fig,'Objects');
Tracks = getappdata(hDFGui.fig,'Tracks');
if hDFGui.mode == 2
    cutoff=str2double(get(hDFGui.eRescueCutoff, 'String'));
    for n=1:length(Tracks)
        if abs(Tracks(n).Event-4.9)<0.1 && Tracks(n).DistanceEventEnd<cutoff
            Tracks(n).TypeTag = [Tracks(n).Type ' tag4'];
        end
    end
end
str=cell(length(Objects),1);
for n = 1:length(Objects)
    velocity=Objects(n).Velocity;
    if isempty(strfind(Objects(n).Comments, '+'))
        hascomments=' ';
    else
        hascomments='+';
    end
    str{n} = [num2str(n) ' ' Objects(n).Name hascomments ' ' Objects(n).Type ' '];
    switch hDFGui.mode 
        case 2
        segtagauto=Objects(n).SegTagAuto;
        nResAuto=sum(abs(segtagauto(:,3)-4.85)<0.1&segtagauto(:,4)>cutoff);%to get 4.8 (stops of shrinkages not captured) and 4.9
        nCatAuto=sum(abs(segtagauto(:,3)-1.85)<0.1|abs(segtagauto(:,3)-4.8)<0.1); %to get 1.8 (catastrophes not captured) and 1.9
        str{n}=[str{n} num2str(Objects(n).CatRes(1)) '|' num2str(nCatAuto) '    ' num2str(Objects(n).CatRes(2)) '|' num2str(nResAuto) ...
            '    ' num2str(velocity(1), '%2.2f') '    ' num2str(velocity(2), '%2.1f') '    ' Objects(n).Custom.type_intensity];
        case 1
        str{n} = [str{n} '  ' num2str(Objects(n).Concentration, 4) 'nM ' num2str(Objects(n).KCl, 4) 'mM '];
    end
    str{n} = [str{n} ' ' Objects(n).File(1:end-4) '   ' num2str(velocity)];
end
setappdata(hDFGui.fig,'Tracks', Tracks);
DF.Draw(hDFGui);
set(hDFGui.lSelection, 'String', str);
set(hDFGui.lSelection, 'Value', max(1,min(get(hDFGui.lSelection, 'Value'),length(str))));