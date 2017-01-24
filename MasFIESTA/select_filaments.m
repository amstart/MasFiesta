function [ Filament ] = select_filaments(Filament, Channel)
%SELECT_FILAMENTS Summary of this function goes here
%   Detailed explanation goes here
FilSelect = ones(length(Filament),1);
for i=1:length(FilSelect)
    if ~isempty(strfind(Filament(i).Comments, '--'))
        FilSelect(i)=0;
    end
    if Filament(i).Channel~=Channel
        FilSelect(i)=0;
    end
end
Filament = Filament(FilSelect == 1);