%% Create drift corrected max projection using fiesta data:
% Run only thougt imges with drift correction h = image lauf index
% Anlegen des imag Mash, welches verschoben wird.
% test if Pixsize exist

function MaxP = MaxP(Img, Drift, Pixsize)
if (exist('Pixsize', 'var'))
else
    Pixsize = 1
end

[xq,yq] = meshgrid(1:1:size(Img{1,1}, 2), 1:1:size(Img{1,1}, 1)) ;
MaxP= double(Img{1,1});             % load first picture of stack
if (exist('Drift', 'var'))
for m = 2:length(Drift)
    %open the frames with drift correction
      h = Drift(m,1); 
    dxp = Drift(m,2)/Pixsize;
    dyp = Drift(m,3)/Pixsize;
    xqd = xq + dxp;                 % driftcorection
    yqd = yq + dyp;
    ImgS = Img{1,h}; 
    ImgDC = interp2(double(ImgS),xqd,yqd, 'cubic');     %interpolation
    MaxP=max(ImgDC, MaxP);          % Compare to previouse images to find maximum           
end
MaxP = uint16(MaxP); 
else
for m = 2:size(Img,2)
    %open the frames with drift correction
    MaxP=max(double(Img{1,m}), MaxP);          % Compare to previouse images to find maximum           
end
MaxP = uint16(MaxP); 
end

end
