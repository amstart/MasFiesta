function fJKConvertTags(direction)
%FJKCONVERTTAGS Summary of this function goes here
%   Detailed explanation goes here
global Filament
global Molecule
if direction==1
    for i=1:length(Filament)
        Filament(i).Results(:,end)=Convertforward(Filament(i).Results(:,end));
    end
    for i=1:length(Molecule)
        Molecule(i).Results(:,end)=Convertforward(Molecule(i).Results(:,end));
    end
else
    for i=1:length(Filament)
        Filament(i).Results(:,end)=Convertbackward(Filament(i).Results(:,end));
    end
    for i=1:length(Molecule)
        Molecule(i).Results(:,end)=Convertbackward(Molecule(i).Results(:,end));
    end
end

function newfloat = Convertforward(float)
tags = fliplr(dec2bin(float)=='1');
rows = size(tags,1);
missed = tags(:,1);
newtags = [missed zeros(rows, 10)];
if size(tags,2)>1
    columns = min(16, size(tags,2));
    tags = tags(:,2:columns);
    for i = 1:rows
        for j=1:columns-1
            if tags(i,j)
                newtags(i, 5) = j;
                break
            end
        end
    end
end
newfloat = fJKtags2float(newtags);

function newfloat = Convertbackward(float)
tags = fJKfloat2tags(float);
newfloat = tags(:,1); %already with interpolated
for row=(find(tags(:,5)>0))'
    newfloat(row) = newfloat(row) + 2^(tags(row,5));
end

