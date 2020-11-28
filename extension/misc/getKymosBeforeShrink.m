t = Tracks([Tracks.Shrinks]);

k = {};
c = 0;
for i = 1:length(tracks)
for j = 1:length(tracks{i})
c = c + 1;
k{c} = tracks{i}{j};
end
end

for i=1:length(k)
for j = 1:length(k{i})
I = k{i}{j}{2}; k{i}{j}{2} = (nansum(I, 1)-sum(~isnan(I),1).*min(min(double(I), [], 1)));
% if length(k{i}{j}{2}) > 1 && length(t(i).FitData) > 1
% x = double((((0:size(k{i}{j}{2},2)-1)-28)*(157/4)) - t(i).Data(2,2));
% [~, id] = min(abs(x));
% I = k{i}{j}{2}(:,id-1:id+1); k{i}{j}{2} = (nansum(I, 2)-sum(~isnan(I),2).*min(min(double(I), [], 1)))';
% end
end
end

s = cell(size(k));
for i=1:length(k)
    for j = 1:length(k{i})
        if length(k{i}{j}{2}) > 1
            s{i} = vertcat(s{i},k{i}{j}{2});
        else
            l = max([size(s{i},2) size(k{i}{2}{2},2) size(k{i}{3}{2},2) size(k{i}{end}{2},2)]);
            s{i} = vertcat(s{i},nan(1,l));
        end
    end
end

f = cell(size(k));
for i=1:length(k)
    for j = 1:length(k{i})
        f{i} = vertcat(f{i},k{i}{j}{1});
    end
end

for i = 1:length(t)
    for j = 1
        t(i).itrace = s{i}/t(i).IntensityPerMAP;
        t(i).frames = f{i};
%         if size(s{i},2) == 9
%             t(i).PSFsample = s{i}/t(i).IntensityPerMAP;
%         else
%             t(i).PSFsample = nan;
%         end
    end
end


Tracks([Tracks.Shrinks]) = t;