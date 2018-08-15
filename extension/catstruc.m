function [ res2 ] = catstruc( res1,res2 )
%CATSTRUC Summary of this function goes here
%   Detailed explanation goes here

res1fields = fieldnames(res1);
res2fields = fieldnames(res2);

%add fields that are in res2 but not in res1
res1copy = res1;
for K = 1 : length(res2fields)
  thisfield = res2fields{K};
  if ~ismember(thisfield, res1fields)
    res1copy(1).(thisfield) = [];   %create the field, make it empty
  end
end

%add fields that are in res1 but not in res2
res2copy = res2;
for K = 1 : length(res1fields)
  thisfield = res1fields{K};
  if ~ismember(thisfield, res2fields)
    res2copy(1).(thisfield) = [];   %create the field, make it empty
  end
end
res2 = [res2copy, res1copy];

