function [GFP] = fJKPlotIntensity(Object,IevalLength,MTend, varargin)
%PLOTINTENSITY Summary of this function goes here
%   Detailed explanation goes here
if MTend>1
    MTend=2;
end
if isfield(Object.Custom, 'Intensity')
    GFP=nan(size(Object.Results,1),1);
    if ~isempty(Object.Custom.Intensity)
        for i=1:size(Object.Results,1)
%             if CalcDistance(Object.Data{i}(1,1:2), Object.PosStart(i,:))>CalcDistance(Object.Data{i}(1,1:2), Object.PosEnd(i,:))
%                 warning(['PosStart and PosEnd warning. Data flipped. i=' num2str(i)]);
%             end
            I = Object.Custom.Intensity{i}(:,MTend);
            last=min(length(I),IevalLength);
            if last>length(I)&&~all(isnan(I))
                warning(['Filament too short: ' Object.Name]);
                GFP(i)=NaN;
                continue
            end
            GFP(i)=sum(I(1:last))/(last*Object.PixelSize);
            if i>3
                if isnan(Object.Custom.Intensity{i-1}(:,MTend)) %replaces unknown values with averages on sides
                    GFP(i-1)=(GFP(i-2)+GFP(i))/2;
                end
            end
        end
    end
else
    GFP=zeros(size(Object.Results,1),1);
end
