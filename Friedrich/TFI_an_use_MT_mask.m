%% Analyse intensity data use MT as mask by FS 18.10.2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2013/10/29  
% Revision: 1
% Written by Friedrich Schwarz
%
% FUNKTION
% Generation of Sub-pixel resolved Image "SuperResolution" from Full
% labeled Microtubulie  Locolisation Microscopy data. "Thinkerbell function"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

% Add bin path to matlab folder
if ~isdeployed
  addpath('bin');
end 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIESTA Data:  data = load('xxx.mat');
% Images:       data.ImgS = StackRead('xxx.stk');
disp('Step = 0')
% OPEN FIESTA DATA
% Set path dir via standard GUI interface
[FileName, PathName] = uigetfile2({'*.mat','FIESTA Data(*.mat)'},'Image Stacks');
FIESTA_path = PathName; 
FIESTA_File = FileName;
fullpath = fullfile(PathName,FileName);                                     % Erzeuge full path adress
load(fullpath);                                                      % Open data
% OPEN corresponding Image DATA_MT
[FileName, PathName] = uigetfile2('*.stk;*.zvi;*.tif;*.tiff','Load MT images');
fullpath = fullfile(PathName,FileName);                                     % Erzeuge full path adress
Img_MT = StackRead(fullpath);
% OPEN corresponding Image DATA_GFP
[FileName, PathName] = uigetfile2('*.stk;*.zvi;*.tif;*.tiff','Load GFP images');
fullpath = fullfile(PathName,FileName);                                     % Erzeuge full path adress
Img_GFP = StackRead(fullpath);

% extract centerlines

fFObPos(Img_MT, Filament, Config)

edges{1}=1:1:size(Img_MT{1,1},1);
edges{2}=1:1:size(Img_MT{1,1},2);
% create histogram
histo = cloudPlot(FObPos(:,1), FObPos(:,2),[1 size(Img_MT{1,1},1) 1 size(Img_MT{1,1},2)],1, [size(Img_MT{1,1},1) size(Img_MT{1,1},2)]);

hist3mat = histo.CData;
% transfer to binar
binaryImage = hist3mat > 0;

% Create image filter
in=strel('octagon',3); %Create morphological structuring element
space=strel('octagon',6); %Create morphological structuring element
out=strel('octagon',9); %Create morphological structuring element
Cluster_bin_in=imdilate(binaryImage,in); % dilate image
Cluster_bin_space=imdilate(binaryImage,space); % dilate image
Cluster_bin_out=imdilate(binaryImage,out); % dilate image

%% Test that filter works
% IMG = double(Img_MT{1,1});
% test2 = IMG.*Cluster_bin_in;
% B= sum(test2(:));


%% Normen:
%
Mtl_tot= sum(MtL);
Pixel_in = sum(Cluster_bin_in(:));
Pixel_space = sum(Cluster_bin_space(:));
Pixel_out = sum(Cluster_bin_out(:));


DATA= Img_MT;
Int_Mt = [];
Int_Spacer= [];
Int_out = [];
for i=1:length(DATA)
Int_Mt = [Int_Mt [sum(DATA{1,i}(Cluster_bin_in)) mean(double(DATA{1,i}(Cluster_bin_in))) std(double(DATA{1,i}(Cluster_bin_in)))]'];
Int_Spacer = [Int_Spacer [sum(DATA{1,i}(Cluster_bin_space)) mean(double(DATA{1,i}(Cluster_bin_space))) std(double(DATA{1,i}(Cluster_bin_space)))]'];
Int_out = [Int_out [sum(DATA{1,i}(Cluster_bin_out)) mean(double(DATA{1,i}(Cluster_bin_out))) std(double(DATA{1,i}(Cluster_bin_out)))...
    mean(double(DATA{1,i}(Cluster_bin_out)))*Pixel_in std(double(DATA{1,i}(Cluster_bin_out)))*Pixel_in]'];
end

SN = (Int_Mt(1,:)-Int_out(4,:))./Int_out(5,:);
meanSD_MT=mean(SN)
devSN_MT=std(SN)


DATA= Img_GFP;
Int_Mt = [];
Int_Spacer= [];
Int_out = [];
for i=1:length(DATA)
Int_Mt = [Int_Mt [sum(DATA{1,i}(Cluster_bin_in)) mean(double(DATA{1,i}(Cluster_bin_in))) std(double(DATA{1,i}(Cluster_bin_in)))]'];
Int_Spacer = [Int_Spacer [sum(DATA{1,i}(Cluster_bin_space)) mean(double(DATA{1,i}(Cluster_bin_space))) std(double(DATA{1,i}(Cluster_bin_space)))]'];
Int_out = [Int_out [sum(DATA{1,i}(Cluster_bin_out)) mean(double(DATA{1,i}(Cluster_bin_out))) std(double(DATA{1,i}(Cluster_bin_out)))...
    mean(double(DATA{1,i}(Cluster_bin_out)))*Pixel_in std(double(DATA{1,i}(Cluster_bin_out)))*Pixel_in]'];
end

SN = (Int_Mt(1,:)-Int_out(4,:))./Int_out(5,:);
meanSD_GFP=mean(SN(250:290))
devSN_GFP=std(SN(217:290))


plot(SN)
