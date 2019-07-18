figure
global Stack
movie = Stack{1};
matrix = nan(length(Molecule), size(movie,3));
for i = 1:length(Molecule)
    f = Molecule(i).Results(:,1);
    x = round(Molecule(i).Results(:,3)./Molecule(i).PixelSize);
    y = round(Molecule(i).Results(:,4)./Molecule(i).PixelSize);
    bgmean = nan(size(f));
    sumimg = nan(size(f));
    for j=1:length(f)
        img = double(movie(y(j)-3:y(j)+3, x(j)-3:x(j)+3, f(j)));
        bg = double(movie(y(j)-3:y(j)+3, [x(j)+8:x(j)+10; x(j)-10:x(j)-8], f(j)));
%         bg = double(movie([y(j)+5:y(j)+8; y(j)-8:y(j)-5], x(j)-3:x(j)+3, f(j)));
        bgmean(j) = mean(bg(:));
        sumimg(j) = sum(img(:));
        matrix(i,j) = sumimg(j)-numel(img)*bgmean(j);
    end
end
iosr.statistics.boxPlot(matrix', 'sampleSize', true, 'scatterAlpha', 1, 'showScatter', true, 'medianColor','r')
med = median(nanmedian(matrix,2));
iqr(nanmedian(matrix,2))