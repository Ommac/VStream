%% Experiment description
%
% Number of layers of the net: 2
% Employed dataset: SBLC
%
% Transformations:
%   Independent scaling, translation and rotation on a uniform
%   background
%
% Binary classification, 1.jpg (car) vs 4673.jpg (plane)

close all;
clear all;

%% Load images and infer parameters

load_prefixname = 'exp_2A_SBLC';

input = load([load_prefixname '_images.mat'], 'images');
images = input.images;
input = load([load_prefixname '_translated_images.mat'], 'translated_images');
translated_images = input.translated_images;
input = load([load_prefixname '_rotated_images.mat'], 'rotated_images');
rotated_images = input.rotated_images;
input = load([load_prefixname '_scaled_images.mat'], 'scaled_images');
scaled_images = input.scaled_images;

n_images = length(images);
n_xtranslations = size(translated_images, 2);
n_ytranslations = size(translated_images, 3);
n_rotations = size(rotated_images,2);
n_scales = size(scaled_images,2);

%% Load templates of layer 1

%T = load('gabor_filters.mat');
T = load('pascal_filters_5.mat');

gabors = T.templates;

%% Load templates of layer 2

%T = load('templatesL2.mat');
%T = load('templatesL2_gabor.mat');
T = load('templatesL2-5_L1-5_range0.5.mat');

templatesL2_hist = T.templatesL2_hist;
%templatesL2_moms = T.templatesL2_moms;

%% Init data structure for responses

% set parameters for histogram computation at C1 & C2 layers
n_splits = T.n_splits; % the image is divided in a grid of n_splits x n_splits regions

%%%% NOTE: the # of bins should be made customizable between layers!
n_binsL1 = T.n_bins; % bars of the histograms at L1
n_binsL2 = T.n_bins; % bars of the histogram at L2
n_bins = T.n_bins; % bars of the histograms at L1
range = T.range; % range of the histogram

rangeL2 = [-0.001 0.001];

% init data structures which will contain the output signatures
S1 = cell(n_images, 1);
C1 = cell(n_images, 1);
S2 = cell(n_images, 1);
C2 = cell(n_images, 1);
S1transl = cell(n_images, n_xtranslations, n_ytranslations);
C1transl = cell(n_images, n_xtranslations, n_ytranslations);
S2transl = cell(n_images, n_xtranslations, n_ytranslations);
C2transl = cell(n_images, n_xtranslations, n_ytranslations);
S1rot = cell(n_images, n_rotations);
C1rot = cell(n_images, n_rotations);
S2rot = cell(n_images, n_rotations);
C2rot = cell(n_images, n_rotations);
S1scale = cell(n_images, n_scales);
C1scale = cell(n_images, n_scales);
S2scale = cell(n_images, n_scales);
C2scale = cell(n_images, n_scales);

%% S1 responses 

% output of dotproductL1_giulia is of format
% cell(n_scales, 1)
% responses{idx_scale} = zeros(n_templates, n_ori, sizeY-(taps(idx_scale)-1), sizeX-(taps(idx_scale)-1))

for idx_image=1:n_images
    S1{idx_image} = dotproductL1_giulia(images{idx_image}, gabors, n_splits);
end

for idx_image=1:n_images
    for ix_transl=1:n_xtranslations
        for iy_transl=1:n_ytranslations
            S1transl{idx_image, ix_transl, iy_transl} = dotproductL1_giulia(translated_images{idx_image, ix_transl, iy_transl}, gabors, n_splits);
        end
    end
end

for idx_image=1:n_images
    for idx_rot=1:n_rotations
        S1rot{idx_image, idx_rot} = dotproductL1_giulia(rotated_images{idx_image, idx_rot}, gabors, n_splits);
    end
end

for idx_image=1:n_images
    for idx_scale=1:n_scales
        S1scale{idx_image, idx_scale} = dotproductL1_giulia(scaled_images{idx_image, idx_scale}, gabors, n_splits);
    end
end

%% C1 responses
 
% output of poolingL1_giulia is of format
% zeros(n_binsL1, n_reg, n_templatesL1, 2)

for idx_image=1:n_images
   histograms = poolingL1_giulia(S1{idx_image}, n_splits, n_binsL1, range,  'histogram');
   signature = histograms(:, :, :, 1);
   signature = signature(:);
   C1{idx_image} = signature;
end


for idx_image=1:n_images
    for ix_transl=1:n_xtranslations
        for iy_transl=1:n_ytranslations
            histograms = poolingL1_giulia(S1transl{idx_image, ix_transl, iy_transl}, n_splits, n_binsL1, range,  'histogram');
            signature = histograms(:, :, :, 1);
            signature = signature(:); 
            C1transl{idx_image, ix_transl, iy_transl} = signature;
        end
    end
end

for idx_image=1:n_images
    for idx_rot=1:n_rotations
        histograms = poolingL1_giulia(S1rot{idx_image, idx_rot}, n_splits, n_binsL1, range,  'histogram');
        signature = histograms(:, :, :, 1);
        signature = signature(:); 
        C1rot{idx_image, idx_rot} = signature;
    end
end

for idx_image=1:n_images
    for idx_scale=1:n_scales
        histograms = poolingL1_giulia(S1scale{idx_image, idx_scale}, n_splits, n_binsL1, range,  'histogram');
        signature = histograms(:, :, :, 1);
        signature = signature(:); 
        C1scale{idx_image, idx_scale} = signature;
    end
end

clear S1*

%% S2 responses 

% output of dotproductL2_giulia is of format
% zeros(signature_length, n_oriL2, n_scalesL2, n_templatesL2)
% signature_length = n_bins * n_reg * n_templatesL1

for idx_image=1:n_images
   S2{idx_image} = dotproductL2_giulia(C1{idx_image}, templatesL2_hist);
end

for idx_image=1:n_images
    for ix_transl=1:n_xtranslations
        for iy_transl=1:n_ytranslations
            S2transl{idx_image, ix_transl, iy_transl} = dotproductL2_giulia(C1transl{idx_image, ix_transl, iy_transl}, templatesL2_hist);
        end
    end
end

for idx_image=1:n_images
    for idx_rot=1:n_rotations
        S2rot{idx_image, idx_rot} = dotproductL2_giulia(C1rot{idx_image, idx_rot}, templatesL2_hist);
    end
end

for idx_image=1:n_images
    for idx_scale=1:n_scales
        S2scale{idx_image, idx_scale} = dotproductL2_giulia(C1scale{idx_image, idx_scale}, templatesL2_hist);
    end
end

%clear C1*
%% C2 responses

% output of poolingL2_giulia is of format
% zeros(n_bins, n_templatesL2, 2)

C2tot = cell(n_images, 1);

for idx_image=1:n_images
    histograms = poolingL2_giulia(S2{idx_image}, n_binsL2, rangeL2,  'histogram');
    signature = histograms(:, :, 1);
    signature = signature(:); 
    C2{idx_image} = signature';
    C2tot{idx_image} = [ C2tot{idx_image} ; C2{idx_image} ];
end

for idx_image=1:n_images
    for ix_transl=1:n_xtranslations
        for iy_transl=1:n_ytranslations
            histograms = poolingL2_giulia(S2transl{idx_image, ix_transl, iy_transl}, n_binsL2, rangeL2,  'histogram');
            signature = histograms(:, :, 1);
            signature = signature(:); 
            C2transl{idx_image, ix_transl, iy_transl} = signature';
            C2tot{idx_image} = [ C2tot{idx_image} ; C2transl{idx_image, ix_transl, iy_transl} ];    
        end
    end
end

for idx_image=1:n_images
    for idx_rot=1:n_rotations
        histograms = poolingL2_giulia(S2rot{idx_image, idx_rot}, n_binsL2, rangeL2,  'histogram');
        signature = histograms(:, :, 1);
        signature = signature(:); 
        C2rot{idx_image, idx_rot} = signature';
        C2tot{idx_image} = [ C2tot{idx_image} ; C2rot{idx_image, idx_rot}  ];
    end
end

for idx_image=1:n_images
    for idx_scale=1:n_scales
        histograms = poolingL2_giulia(S2scale{idx_image, idx_scale}, n_binsL2, rangeL2,  'histogram');
        signature = histograms(:, :, 1);
        signature = signature(:); 
        C2scale{idx_image, idx_scale} = signature';
        C2tot{idx_image} = [ C2tot{idx_image} ; C2scale{idx_image, idx_scale} ];
    end
end

clear S2*

%% Response visualization and quantitative comaprison

for idx_image = 1:n_images
    % Create separate images for each class of objects
    figure( idx_image )
    m = mean(C2tot{idx_image});
    sd = std(C2tot{idx_image});
    f = [ m+3*sd , flipdim(m-3*sd,2)]; 
    fill([1:size(C2tot{idx_image},2) , size(C2tot{idx_image},2):-1:1] , f, [7 7 7]/8)
    hold on;
    plot(1:size(C2tot{idx_image},2) , m , 'b' , 'LineWidth',1);
    max(sd)
end

% Compute inter-class signature similarity

% Class 1
mSim1 = 0;
for i = 1:size(C2tot{1},1)
    for j = i+1:size(C2tot{1},1)

        mSim1 = mSim1 + similarity(C2tot{1}(i,:),C2tot{1}(j,:));
    end
end
mSim1 = mSim1*2/(size(C2tot{1},1)^2-size(C2tot{1},1))

% Class 2
mSim2 = 0;
for i = 1:size(C2tot{2},1)
    for j = i+1:size(C2tot{2},1)

        mSim2 = mSim2 + similarity(C2tot{2}(i,:),C2tot{2}(j,:));
    end
end
mSim2 = mSim2*2/(size(C2tot{2},1)^2-size(C2tot{2},1))

% Compute similarity between signatures of separate classes 

mSimCross = 0;
for i = 1:size(C2tot{1},1)
    for j = 1:size(C2tot{2},1)

        mSimCross = mSimCross + similarity(C2tot{1}(i,:),C2tot{2}(j,:));
    end
end
mSimCross = mSimCross/(size(C2tot{1,:},1)*size(C2tot{2,:},1))

%% Binary classifier

Y1 = ones(size(C2tot{1},1),1);
Y2 = -ones(size(C2tot{2},1),1);

% Randomly split the dataset between training and testing

n_train = 10;
n_test = 40;

% Run classifier some times
numClassRuns = 200;
missErr = [];
for iClass = 1:numClassRuns

    [Xtr1, Ytr1, Xts1, Yts1] = randomSplitDataset(C2tot{1}, Y1, floor(n_train/2), floor(n_test/2));
    [Xtr2, Ytr2, Xts2, Yts2] = randomSplitDataset(C2tot{2}, Y2, floor(n_train/2), floor(n_test/2));

    Xtr = [Xtr1 ; Xtr2];
    Ytr = [Ytr1 ; Ytr2];
    Xts = [Xts1 ; Xts2];
    Yts = [Yts1 ; Yts2];

    % Apply 1-NN classification
    k = 1;
    Ypred = kNNClassify(Xtr, Ytr, k, Xts);
    ind = find((sign(Ypred) ~= sign(Yts)));
    %[Yts  Ypred ]
    missErr = [ missErr (numel(ind)/n_test) ];
end
empErrM = mean(missErr)
empErrV = var(missErr,1)