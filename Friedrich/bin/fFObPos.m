% Thinkerbell_SupRes_read_fiesta_objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2013/10/29  
% Revision: 2
% Written by Friedrich Schwarz
%
% FUNKTION
% Read Fiesta tracking results Object data  Locolisation Microscopy data. "Thinkerbell function"
%
% USING THIS SCRIPT:
% Use this function as part of the Thinkerbell script
%
% NOTES
%   
%
% REQUIRED INPUTS -
% these must be available:
%
% FIESTA Data:  data = load('xxx.mat');
% SupResSet     % Start/end Frame, LinScal,MT_LengthMin
%
% OUTPUT
% SupResPos = [x,y] in nm
% SupResParameter = [Frame, Filament, Fit Intensity, BGfit, AOI]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yy=fFObPos(Img_MT, Filament, Config)
tic
FObPos=[]; % told for parameters
MtL=[];
% Set frames fix to hole batch
for h = 1: length(Filament)
    
    MtL = [MtL (mean(Filament(1, h).Results(:,7))*Config.LastFrame)'];
    for k = 1:length(Filament(1, h).Data);
                % Ausgabe der Positions         
    FObPos = [FObPos; Filament(1, h).Data{1,k}(:,1:2)];
    end
      
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normelize data to Pixsize and conveted to single pricies
FObPos = single(FObPos/Config.PixSize);
%Write variables to main workspace.
assignin('base','FObPos',FObPos);
assignin('base','MtL',MtL');
toc
end


