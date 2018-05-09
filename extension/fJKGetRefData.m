function [refdata] = fJKGetRefData(Object, mode, reftags, varargin)
%FGETREFDATA Summary of this function goes here
%   Detailed explanation goes here
global Filament;
global Molecule;
refcommentstart=strfind(Object.Comments,'ref:');
found=0;
Object.Results(:,5) = [];
if isfield(Object, 'PosCenter');
    Object.PosStart(:,3) = [];
    Object.PosCenter(:,3) = [];
    Object.PosEnd(:,3) = [];
end
if ~isempty(refcommentstart)
    restcomment=Object.Comments(refcommentstart+4:end);
    if isempty(strfind(restcomment,'-'))
        refdata=nan;
        return
    end
    dash=strfind(restcomment,'-');
    refname=restcomment(1:dash(1)-1);
    space=strfind(restcomment(dash(1)+1:end),' ');
    if isempty(space)
        space=length(restcomment(dash(1)+1:end))+1;
    end
    refmode=restcomment(dash(1)+1:dash(1)+space(1)-1);
    if nargin==3
        for i=1:length(Filament)
            if strcmp(Filament(i).Name, refname)
                Reference=Filament(i);
                found=1;
                break
            end
        end
        if ~found
            for i=1:length(Molecule)
                if strcmp(Molecule(i).Name, refname)
                    Reference=Molecule(i);
                    found=1;
                    break
                end
            end
        end
    else
        RefObjects = varargin{1};
        for i=1:length(RefObjects)
            if strcmp(RefObjects(i).Name, refname)
                Reference=RefObjects(i);
                found=1;
                break
            end
        end
    end
    if ~found
        refdata=nan;
        return
    end
    Reference.Results(:,5) = [];
    if isfield(Object, 'PosCenter');
        Reference.PosStart(:,3) = [];
        Reference.PosCenter(:,3) = [];
        Reference.PosEnd(:,3) = [];
    end
else
    if isempty(reftags)
        [~, refpoint] = min(Object.Results(:,6));
    elseif reftags(1)
        refpoint = reftags(1);
    else
        refdata=nan;
        return
    end
    Object.Results(:,5:end) = [];
    Reference=Object;
    Reference.Results(:,:)=repmat(Reference.Results(refpoint,:),size(Reference.Results,1),1);
    if isfield(Object, 'PosCenter');
        Reference.PosStart(:,:)=repmat(Reference.PosStart(refpoint,:),size(Reference.Results,1),1);
        Reference.PosCenter(:,:)=repmat(Reference.PosCenter(refpoint,:),size(Reference.Results,1),1);
        Reference.PosEnd(:,:)=repmat(Reference.PosEnd(refpoint,:),size(Reference.Results,1),1);
    end
    refmode=[];
end
if size(Object.Results,1)~=size(Reference.Results,1)
    Object.Results(:,5:end) = [];
    Reference.Results(:,5:end) = [];
    if isfield(Object, 'PosCenter');
        objfilfields=[Object.PosStart Object.PosCenter Object.PosEnd];
        objnum=6;
    else
        objfilfields=[];
        objnum=0;
    end
    if isfield(Reference, 'PosCenter');
        reffilfields=[Reference.PosStart Reference.PosCenter Reference.PosEnd];
        refnum=6;
    else
        reffilfields=[];
        refnum=0;
    end
    frames=intersect(Object.Results(:,1),Reference.Results(:,1));
    tmpobj=[Object.Results objfilfields];
    tmpref=[Reference.Results reffilfields];
    tmpnanobj=nan(size(Object.Results,1),size(Object.Results,2)+objnum);
    tmpnanref=nan(size(Object.Results,1),size(Object.Results,2)+refnum);
    [~, objectframes] = ismember(frames, tmpobj(:,1));
    [~, refframes] = ismember(frames, tmpref(:,1));
    tmpnanobj(objectframes,:)=tmpobj(objectframes,:);
    Object.Results=tmpnanobj(:,1:4);
    if objnum
        Object.PosStart=tmpnanobj(:,5:6);
        Object.PosCenter=tmpnanobj(:,7:8);   
        Object.PosEnd=tmpnanobj(:,9:10); 
    end
    tmpnanref(objectframes,:)=tmpref(refframes,:);
    Reference.Results=tmpnanref(:,1:4);
    if refnum
        Reference.PosStart=tmpnanref(:,5:6);
        Reference.PosCenter=tmpnanref(:,7:8);   
        Reference.PosEnd=tmpnanref(:,9:10); 
    end
end
if isempty(refmode)
        if isfield(Object, 'PosStart')&&isfield(Reference, 'PosStart')
            switch mode
                case 1
                    refdata = CalcDistance(Object.PosStart,Reference.PosCenter)-CalcDistance(Reference.PosStart,Reference.PosCenter);
                case 2
                    refdata = CalcDistance(Object.PosCenter,Reference.PosCenter);
                case 3
                    refdata =CalcDistance(Object.PosEnd,Reference.PosCenter)-CalcDistance(Reference.PosEnd,Reference.PosCenter);
                otherwise
                    refdata = nan;
            end
        else
            refdata = CalcDistance(Object.Results(:,3:4),Reference.Results(:,3:4));
        end
else
    switch refmode
        case 's'
            refdata = CalcDistance(Object.Results(:,3:4),Reference.PosStart);
        case 'c'
            refdata = CalcDistance(Object.Results(:,3:4),Reference.PosCenter);
        case 'e'
            refdata = CalcDistance(Object.Results(:,3:4),Reference.PosEnd);
        case 'r'
            refdata = CalcDistance(Object.Results(:,3:4),Reference.Results(:,3:4));
        otherwise
            refdata=nan;
    end
end