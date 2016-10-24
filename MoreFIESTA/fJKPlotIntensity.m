function [GFP] = fJKPlotIntensity(Object,IevalLength,MTend, varargin)
%PLOTINTENSITY Summary of this function goes here
%   Detailed explanation goes here
GFP=nan(size(Object.Results,1),1);
if MTend>1
    MTend=2;
end
if isfield(Object.Custom, 'Intensity')
    if ~isempty(Object.Custom.Intensity);
        for i=1:size(Object.Results,1)
%             if CalcDistance(Object.Data{i}(1,1:2), Object.PosStart(i,:))>CalcDistance(Object.Data{i}(1,1:2), Object.PosEnd(i,:))
%                 warning(['PosStart and PosEnd warning. Data flipped. i=' num2str(i)]);
%             end
            last=min(size(Object.Custom.Intensity{i},1),IevalLength);
            if last>size(Object.Custom.Intensity{i},1)&&~all(isnan(Object.Custom.Intensity{i}(:,MTend)))
                warning(['Filament too short: ' Object.Name]);
                GFP(i)=NaN;
                continue
            end
            GFP(i)=sum(Object.Custom.Intensity{i}(1:last,MTend));
            if i>3
                if isnan(Object.Custom.Intensity{i-1}(:,MTend))
                    GFP(i-1)=(GFP(i-2)+GFP(i))/2;
                end
            end
        end
    end
end
