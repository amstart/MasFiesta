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
function yy=fSupResPos(data, SupResSet)
tic
SupResParameter=[]; % told for parameters
Ob_Pos= []; % To hold [row,col] of fits
SupResDelta= []; % to hold for deta, values [delta x, delta y, delta Ifit, delta BGfit]
% Set frames fix to hole batch
Frames = [1, length(Img_MT)];
for h = Frames(1) : Frames(2)
    %disp(h)
    sd_O = size(Objects{1, h});
    % Test that frame contains Objects
    if sd_O(1)>= 1;
        sd_Os = size(Objects{1, h}.center_x);
                % Ausgabe der Positions             
                Ob_Pos = [SupResPos; [Objects{1, h}.center_x; Objects{1, h}.center_y]'];
                
                idf =single(h*ones(sd_Os(2),1));
                emthy = NaN(sd_Os(2),1);
                data.Objects{1, h}.height;
                norm = 2*sqrt(2*log(2));

                SupResParameter = [SupResParameter; [idf, emthy, data.Objects{1, h}.height(1,:)',...
                    data.Objects{1, h}.background(1,:)', emthy]];
                SupResDelta = [SupResDelta; [(data.Objects{1, h}.width(1,:)/norm)', emthy...
                                            data.Objects{1, h}.height(2,:)',...
                                            data.Objects{1, h}.background(2,:)']];
    end                                     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normelize data to Pixsize and conveted to single pricies
SupResPos = single(SupResPos/data.Config.PixSize);
SupResParameter = single(SupResParameter);
SupResDelta = single(SupResDelta);
%Write variables to main workspace.
assignin('base','SupResPos',SupResPos);
assignin('base','SupResParameter',SupResParameter);
assignin('base','SupResDelta',SupResDelta);
toc
end