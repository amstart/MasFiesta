function [patchkymos, bg] = definePatchBorders(kymos, threshfile, patchappearin, day)
%DEFINEPATCHBORDERS Summary of this function goes here
%   Detailed explanation goes here
ids = threshfile(:,[2 4]); % threshold column
nMT = length(kymos);
patchkymos = cell(1,nMT);
bg = cell(1,nMT);
checkbwareadiff = zeros(1,nMT);
SE = strel('rectangle',[5 10]);
for i = 1:nMT
    threshedkymo = kymos{i};
    bpixels = ids(i*2-1,1):ids(i*2-1,1)+ids(i*2-1,2);
    ppixels = ids(i*2,1):ids(i*2,1)+ids(i*2,2);
    if bpixels(1)
        bg{i} = mean(threshedkymo(:,bpixels),2);
    else
        bg{i} = nan(size(threshedkymo,1));
    end
    if bpixels(1) == ppixels(1) %no patch in kymo
        patchkymos{i} = nan(size(threshedkymo));
        continue
    end
    if strcmp(day, '180516')
        if max(ismember(i, patchappearin))
            patch_existing = [nan(98,1); mean(threshedkymo(99:109,ppixels),2)];
            patch = [patch_existing; repmat(mean(patch_existing(100:106)),222,1)];
        else
            patch_existing = mean(threshedkymo(1:109,ppixels),2);
            patch = [patch_existing; repmat(mean(patch_existing(100:106)),222,1)];
        end
    elseif strcmp(day, '180424')
            patch_existing = mean(threshedkymo(1:1456,ppixels),2);
            patch = [patch_existing; repmat(mean(patch_existing(1300:1456)),718,1)];
            if i==7
                threshedkymo = threshedkymo(:,102:154);
            end
    else
            error('please provide valid day');
    end
    if ~isnan(bg{i}(1))
        thresh = repmat(bg{i}+(patch-bg{i})./2, 1, size(threshedkymo,2));
    else
        thresh = threshedkymo./2;
    end
    bwarea = (threshedkymo - thresh) > 0;
    checkbwareadiff(i) = sum(sum(bwarea));
    bwarea = bwareaopen(bwarea,10);
    bwarea = imclose(bwarea, SE);
    checkbwareadiff(i) = checkbwareadiff(i) - sum(sum(bwarea));
    threshedkymo(~bwarea(:)) = deal(nan);
    patchkymos{i} = threshedkymo;
end

