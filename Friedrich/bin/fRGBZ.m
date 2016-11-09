%% Create drift corrected max projection using fiesta data:
% Run only thougt imges with drift correction h = image lauf index
% Anlegen des imag Mash, welches verschoben wird.
% test if Pixsize exist

function RGBZ = RGBZ(Img)
[xq,yq] = meshgrid(1:1:size(Img{1,1}, 2), 1:1:size(Img{1,1}, 1)) ;

Noblocks = ceil(size(Img,2)/3);
%% red channel
rImgMax= double(Img{1,1});             % load first picture of stack
for m = 2:Noblocks
    %open the frames with drift correction
    rImgMax=max(double(Img{1,m}), rImgMax);          % Compare to previouse images to find maximum           
end
RGBZ(:,:,1) = uint16(rImgMax); 


%% green channel
gImgMax = double(Img{1,Noblocks+1});             % load first picture of stack
for m = Noblocks+2:2*Noblocks
    %open the frames with drift correction
    gImgMax=max(double(Img{1,m}), gImgMax);          % Compare to previouse images to find maximum           
end
RGBZ(:,:,2) = uint16(gImgMax); 

%% blue channel

bImgMax= double(Img{1,2*Noblocks+1});             % load first picture of stack
for m = 2*Noblocks+2:size(Img,2)
    %open the frames with drift correction
    bImgMax=max(double(Img{1,m}), bImgMax);          % Compare to previouse images to find maximum           
end
RGBZ(:,:,3) = uint16(gImgMax); 
end
