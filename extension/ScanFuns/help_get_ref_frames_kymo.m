function [Filament] = help_get_ref_frames_kymo(Filament, shrinkingframes)
%HELP_GET_REF_FRAMES_KYMO Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(Filament)
    Filament(i).ForKymo = {};
    sf = shrinkingframes{i};
    if isstruct(sf)
        for j = 1:length(sf)
            Filament(i).ForKymo{j} = sf(j).Data(1,6)-5:sf(j).Data(end,6)+10;
        end
    else
        Filament(i).ForKymo = [];
    end
end

