function Object=fCalcDrift(Object,Drift,Value, varargin) %JochenK: Moved function to seperate file
if ~isempty(Drift)
    if Value == 1 && Object.Drift == 0
        t = -1; %subtract drift
    elseif Value == 0 && Object.Drift == 1
        t = 1; %add drift
    else
        return;
    end
    nData = size(Object.Results,1);    
    for i=1:nData
        k=find(Drift(:,1)==Object.Results(i,1));
        if length(k)==1
            Object.Results(i,3:5)=Object.Results(i,3:5)+t*Drift(k,2:4);
            if nargin < 4
                if any(isnan(Drift(:,4)))
                    Object.Results(i,9) = Object.Results(i,9) - t* norm(Drift(k,5:6));    
                else
                    Object.Results(i,9) = Object.Results(i,9) - t* norm(Drift(k,4:7));
                end
            end
            if isfield(Object,'PosCenter')
                Object.PosStart(i,:) = Object.PosStart(i,:) + t*Drift(k,2:4);
                Object.PosCenter(i,:) = Object.PosCenter(i,:) + t*Drift(k,2:4);
                Object.PosEnd(i,:) = Object.PosEnd(i,:) + t*Drift(k,2:4);
                Object.Data{i}(:,1) = Object.Data{i}(:,1) + t*Drift(k,2);
                Object.Data{i}(:,2) = Object.Data{i}(:,2) + t*Drift(k,3);  
                Object.Data{i}(:,3) = Object.Data{i}(:,3) + t*Drift(k,4);  
            end
        end
        Object.Results(:,6)=fDis(Object.Results(:,3:5));
    end    
    Object.Drift=Value;
end