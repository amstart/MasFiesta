function [hmin, hmax] = autoadjust( img )
%AUTOTHRESHOLD Summary of this function goes here
%   http://wiki.cmci.info/documents/120206pyip_cooking/python_imagej_cookbook#automatic_brightnesscontrast_button
AUTO_THRESHOLD = 5000;
imgvec = img(:);
pixelCount = length(imgvec);
limit = round(pixelCount/10);
[N, edges] = histcounts(imgvec,256);
threshold = floor(pixelCount/AUTO_THRESHOLD);
i=0;
found = false;
max(edges);
while true
    i = i + 1;
    if N(i) > limit
        N(i) = 0;
    end
    found = N(i) > threshold;
    if found || i>=length(N)
        break
    end
end
hmin = edges(i);
i = 256;
while true
   i = i - 1;
   if N(i) > limit
        N(i) = 0;
   end
   found = N(i)> threshold;
   if found || i<2
      break
   end
end
hmax = edges(i+1);