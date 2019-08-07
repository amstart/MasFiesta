function [Objects] = help_extension_only(Objects,Reference)
%HELP_EXTENSION_ONLY This cuts the Filament off at the reference filament
%end
for i = 1:length(Objects)
    [refpoint, Object] = fJKGetRefData(Objects(i), 0, [], Reference);
    error = 0;
    for j = 1:length(Object.Data)
        x = Object.Data{j}(:,1) - refpoint(j,1);
        y = Object.Data{j}(:,2) - refpoint(j,2);
        d = CalcDistance(Object.Data{j}(:,1:2),refpoint(j,:));
        [~,minid] = min(d);
        if minid == 1
            if diff(sign(x(1:2)))~=0 || diff(sign(y(1:2)))~=0
                id = 1;
            else
                id = [];
            end
        else
            try
            ix = find(diff(sign(x(minid-1:minid+1)))~=0);
            iy = find(diff(sign(y(minid-1:minid+1)))~=0);
            catch
                error = error+1;
                ix = [];
                iy = [];
                id = 1;
            end
            if isempty(iy) || (~isempty(ix) && abs(diff(x(ix:ix+1))) > abs(diff(y(iy:iy+1))))
                id = ix+minid-1;
            else
                id = iy+minid-1;
            end
        end
        if length(id)==1
            Object.Data{j} = [[Object.Data{j}(1:id,1:2); refpoint(j,:)] nan(id+1,1)];
        else
            Object.Data{j} = [refpoint(j,:) nan];
        end
    end
    if error
        ['error with ' Object.Name ' : ' num2str(error)]
    end
    Object.Results = [Object.Results nan(size(Object.Results,1),1)];
    Object.PosCenter = [Object.PosCenter nan(size(Object.PosCenter,1),1)];
    Object.PosStart = [Object.PosStart nan(size(Object.PosStart,1),1)];
    Object.PosEnd = [Object.PosEnd nan(size(Object.PosEnd,1),1)];
    Objects(i) = Object;
end
