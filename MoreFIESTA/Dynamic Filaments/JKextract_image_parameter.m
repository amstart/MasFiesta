%I have used this to compare the intensity of the lamp to the intensity of
%the laser (the LampLaser.mat files, which is a stack with two frames: the
%first taken with the lamp, the second with the laser
[FileName,PathName] = uigetfile(['Z:\Data\Jochen\' '*'], 'Select the stack file');
load('Z:\Data\Jochen\params.mat')
img=StackRead([PathName FileName]);
newimg = cell(1,2);
stats = cell(1,2);
for i = 1:length(img)
    newimg{i} = double(img{i});
    statvec = newimg{i}(~isnan(newimg{i}));
    filterimg = Image2Binary(img{i}, params);
    backgroundvec = newimg{i}(~filterimg);
    background = median(backgroundvec);
    backgroundnoise = std(backgroundvec);
    newimg{i}(~filterimg) = NaN;
    filteredstatvec = newimg{i}(filterimg);
    stats{i} = [background median(statvec) mean(statvec) std(statvec) median(filteredstatvec) mean(filteredstatvec) std(filteredstatvec)];
    newimg{i} = newimg{i} - background;
    newimg{i}(newimg{i}<backgroundnoise) = NaN;
end
newimg{2}(isnan(newimg{1}))= NaN;
newimg{1}(isnan(newimg{2}))= NaN;
factors = imdivide(newimg{1}, newimg{2});
factorvector = factors(~isnan(factors));
splitpathname = strsplit(PathName, '\');
num2clip_jochen([splitpathname{4} char(9) FileName(1) char(9)], [median(factorvector) mean(factorvector) std(factorvector) stats{1} stats{2}])
