function PrepareFils(NewObjects, RefObjects, PathName, FileName)
hDFGui = getappdata(0,'hDFGui');
ref = get(hDFGui.cUsePosEnd, 'Value')*2+1;
fieldnames = {'Selected','Channel','TformMat','Color','PathData', 'Visible', 'PlotHandles', 'Data', 'TrackingResults'};
NewObjects = rmfield(NewObjects,fieldnames);
str=cell(length(NewObjects),1);
deleteobjects = false(length(NewObjects), 1);
external_intensity_name = get(hDFGui.eLoadIntensityFile, 'String');
has_external_intensity = 0;
if ~strcmp(external_intensity_name, '')
    try
        ExtIntensity = load([PathName external_intensity_name '.mat']);
        if isfield(ExtIntensity, 'intensities')
            has_external_intensity = 1;
        end
    catch
    end
end
for i=1:length(NewObjects)
    NewObjects(i).CustomData = [];
    if has_external_intensity
        NewObjects(i).Custom.Intensity = ExtIntensity.intensities{i};
        NewObjects(i).Custom.type_intensity = external_intensity_name;
    else
        if isfield(NewObjects(i).Custom, 'Intensity')
            NewObjects(i).Custom.type_intensity = 'From File';
        else
            NewObjects(i).Custom.type_intensity = 'None';
        end
    end
    str{i}=NewObjects(i).Name;
    typecomment=strfind(NewObjects(i).Comments,'type:');
    if ~isempty(typecomment)
        restcomment=NewObjects(i).Comments(typecomment+5:end);
        space=strfind(restcomment(1:end),' ');
        if isempty(space)
            space=length(restcomment(1:end))+1;
        end
        NewObjects(i).Type=restcomment(1:space(1)-1);
        if strcmp(NewObjects(i).Type, 'unknown')
            deleteobjects(i) = 1;
        end
        if ~isempty(strfind(NewObjects(i).Comments, '--'))
            deleteobjects(i) = 1;
        end
        if strcmp(NewObjects(i).Type(end), 'A')
            NewObjects(i).Type = [NewObjects(i).Type(1:end-1) ' +Ase1'];
        else
            NewObjects(i).Type = [NewObjects(i).Type ' -Ase1'];
        end
    else
        NewObjects(i).Type='n/a';
    end
    NewObjects(i).LoadedFromPath = PathName;
    NewObjects(i).LoadedFromFile = FileName;
end
if ~get(hDFGui.cAllowUnknownTypes, 'Value') % deletes MTs with unknown type
    NewObjects(deleteobjects) = [];
end
for i=1:length(NewObjects)
    tags = fJKfloat2tags(NewObjects(i).Results(:,end));
    if ref==1
        tiptags = tags(:,7);
        tags = tags(:,6);
    else
        tiptags = tags(:,10);
        tags = tags(:,9);
    end
    catastrophes = tags==10;
    rescues = tags==15;
    if ~get(hDFGui.cAllowWithoutReference, 'Value')
        refcomment=strfind(NewObjects(i).Comments,'ref:');
        if ~isempty(refcomment)
            RefPos=fJKGetRefData(NewObjects(i), ref, tags==11, RefObjects);
        else
            RefPos=nan;
        end
    else
        RefPos=fJKGetRefData(NewObjects(i), ref, tags==11, RefObjects);
    end
    if isnan(RefPos)
        DynResults = [nan nan nan 1];
    else
        deleted_rows = [];
        DynResults = [NewObjects(i).Results(:,1:2) RefPos (1:size(RefPos,1))'];
        for m=length(tags):-1:1
            if tags(m)==9||isnan(RefPos(m))
                deleted_rows = [deleted_rows m];
                DynResults(m,:) = [];
                tags(m) = [];
                tiptags(m) = [];
            end
        end
    end
    NewObjects(i).Deleted_Rows = deleted_rows;
    NewObjects(i).CatRes = [sum(catastrophes) sum(rescues)];
    NewObjects(i).Tags = [tags tiptags];
    NewObjects(i).DynResults = DynResults;
    NewObjects(i).SegTagAuto=[NaN NaN NaN NaN NaN];
    NewObjects(i).Velocity=nan(1,2);
    NewObjects(i).Duration = 0;
    NewObjects(i).Disregard = 0;
    NewObjects(i).TrackIds = 0;
end
OldObjects = getappdata(hDFGui.fig,'Objects');
if ~isempty(OldObjects)
    NewObjects = [OldObjects NewObjects];
end
setappdata(hDFGui.fig,'Objects',NewObjects);
set(hDFGui.cUsePosEnd, 'Enable', 'off');
setappdata(0,'hDFGui',hDFGui);