clear all;
close all;

%% Random patches

%% Parameters


n_ori = 8;
res_ori = 2*pi / n_ori;
ori = (0:(n_ori-1))*res_ori;

n_scales = 3;
taps = [11 23 47];

n_transformations = n_ori * n_scales;

n_templates = 2;

n_filters = n_templates * n_transformations;

%% Source images

%load('compute_templates/pascal_filters.mat');

%% Gabors 

load('compute_templates/gabor_filters.mat');

%% Parameters


%% Import, normalize and zero-center the input image
inputImg1 = double(rgb2gray(imread('plane.jpg','jpg')));
inputImg1  = inputImg1 - mean(mean(inputImg1));
inputImg1 = inputImg1 ./ norm(inputImg1, 1);
[inSizeXini inSizeYini] = size(inputImg1);

signatures = [];

numTraslX = 4; % Number of translations along X of the input image 
rangeTraslX = 50; % Range of translations along X of the input image
numTraslY = 4; % Number of translations along Y of the input image 
rangeTraslY = 50; % Range of translations along Y of the input image

for ix = 0:numTraslX
for iy = 0:numTraslY

    inputImg = imtranslate(inputImg1,[ix * floor(rangeTraslX/numTraslX) - floor(rangeTraslX/2) , iy * floor(rangeTraslY/numTraslY) - floor(rangeTraslY/2) ]);
    
     inputImg = imcrop( inputImg ,[ ceil(rangeTraslX/2) ceil(rangeTraslX/2) floor(inSizeXini - rangeTraslX) floor(inSizeYini - rangeTraslY) ]);
     [inSizeX inSizeY] = size(inputImg);    
    
    figure(1)
    subplot(numTraslX+1, numTraslY+1, ix*(numTraslX+1) + iy + 1);
    imshow(inputImg, []);
    % Simple layer

    filteredImg = filtering( inputImg , templates );

    % figure;
    % imshow(cell2mat(filteredImg(1,1,1)) , []);

    % Complex layer

    % Image pooling
    poolingSplitNum = 1;    % Number of splits along axes for determining pooling regions
    numBars = 100;   % Number of bars of the histogram

    L1hist = pooling( filteredImg , n_templates , poolingSplitNum , numBars , 'histogram');

    %bar(L1hist{2,1,2},L1hist{2,1,1});

    % Generate pooling area 1 signature by concatenating histograms generated
    % by the filtering with all templates
    signatures = [signatures ; horzcat(L1hist{:,1,1})];
    
end
end

%% Response visualization and quantitative comaprison

figure(2)
%plot(signatures');
%boxplot(signatures);

m = mean(signatures);
sd = std(signatures);
f = [ m+2*sd , flipdim(m-2*sd,2)]; 
fill([1:size(signatures,2) , size(signatures,2):-1:1] , f, [7 7 7]/8)
hold on;
plot(1:size(signatures,2) , m , 'b' , 'LineWidth',1);

max(sd)