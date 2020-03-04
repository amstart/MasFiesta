function [Filament] = help_get_ref_frames_kymo(Filament, shrinkingframes)
%HELP_GET_REF_FRAMES_KYMO Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(Filament)
    if length(shrinkingframes{i}) == 1 || isempty(shrinkingframes{i})
        Filament(i).FramesForKymo = 1:length(Filament(i).Results(:,1));
        continue
    end
    mf = shrinkingframes{i}(:,2);
    jumpmf = [12; diff(mf)]-1>10;
    mf = mf(jumpmf);
    f = Filament(i).Results(:,1);
    newf = f;
    newf(:) = find(~(f-mf(1)));
    for j = 2:length(mf)
        newf(f>mf(j)-15) = find(~(f-mf(j)));
    end
    Filament(i).FramesForKymo(:,1) = newf;
end

