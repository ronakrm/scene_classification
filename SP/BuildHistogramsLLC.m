function [ H_all ] = BuildHistogramsLLC( imageFileList,imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig )
%function [ H_all ] = BuildHistograms( imageFileList, dataBaseDir, featureSuffix, params, canSkip )
%
%find texton labels of patches and compute texton histograms of all images
%
% For each image the set of sift descriptors is loaded and then each
%  descriptor is labeled with its texton label. Then the global histogram
%  is calculated for the image. If you wish to just use the Bag of Features
%  image descriptor you can stop at this step, H_all is the histogram or
%  Bag of Features descriptor for all input images.
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image file
% featureSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the feature textons and coordinates.
%  Its default value is '_sift.mat'.
% dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% canSkip: if true the calculation will be skipped if the appropriate data
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Histograms\n\n');

%% parameters

if(~exist('params','var'))
    params.maxImageSize = 1000;
    params.gridSpacing = 8;
    params.patchSize = 16;
    params.dictionarySize = 200;
    params.numTextonImages = 50;
    params.pyramidLevels = 3;
end
if(~isfield(params,'maxImageSize'))
    params.maxImageSize = 1000;
end
if(~isfield(params,'gridSpacing'))
    params.gridSpacing = 8;
end
if(~isfield(params,'patchSize'))
    params.patchSize = 16;
end
if(~isfield(params,'dictionarySize'))
    params.dictionarySize = 200;
end
if(~isfield(params,'numTextonImages'))
    params.numTextonImages = 50;
end
if(~isfield(params,'pyramidLevels'))
    params.pyramidLevels = 3;
end
if(~exist('canSkip','var'))
    canSkip = 1;
end
%% load texton dictionary (all texton centers)

inFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));
load(inFName,'dictionary');
fprintf('Loaded texton dictionary: %d textons\n', params.dictionarySize);

%% compute texton labels of patches and whole-image histograms
H_all = [];
if(exist('pfig','var'))
    %tic;
end
for f = 1:length(imageFileList)
    
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    end
    outFName = fullfile(dataBaseDir, sprintf('%s_texton_ind_%d.mat', baseFName, params.dictionarySize));
    outFName2 = fullfile(dataBaseDir, sprintf('%s_hist_%d.mat', baseFName, params.dictionarySize));
    if(exist(outFName,'file')~=0 && exist(outFName2,'file')~=0 && canSkip)
        %fprintf('Skipping %s\n', imageFName);
        if(nargout>1)
            load(outFName2, 'H');
            H_all = [H_all; H];
        end
        continue;
    end
    
    %% load sift descriptors
    if(exist(inFName,'file'))
        load(inFName, 'features');
    else
        features = sp_gen_sift(fullfile(imageBaseDir, imageFName),params);
    end
    ndata = size(features.data,1);
    if(exist('pfig','var'))
        sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    end
    %fprintf('Loaded %s, %d descriptors\n', inFName, ndata);
    
    %% find texton indices and compute histogram
    texton_ind.data = zeros(ndata,params.nearestNeighbor,2);
    texton_ind.x = features.x;
    texton_ind.y = features.y;
    texton_ind.wid = features.wid;
    texton_ind.hgt = features.hgt;
    %run in batches to keep the memory foot print small
    batchSize = 100000;
    
    num_neighbors = params.nearestNeighbor;
    
    if ndata <= batchSize
        
        % get distances from each image feature to all dictionary codewords
        dist_mat = sp_dist2(features.data, dictionary);
        
        % sort the distances for each image feature
        [sorted_distances d_codes] = sort(dist_mat,2);
        
        % only care about nearest neighbors
        d_codes = d_codes(:,1:num_neighbors);
        
        
        % construct histogram
        tmp_hist = zeros(params.dictionarySize,1);
        
        for f=1:ndata
            x = features.data(f,:)';
            
            B = dictionary(d_codes(f,:),:);
            
            one = ones(num_neighbors, 1);
            
            % compute data covariance matrix
            B_1x = B - one *x';
            C = B_1x * B_1x';
            
            % reconstruct LLC code
            c_hat = C \ one;
            c_hat = c_hat /sum(c_hat);
            
            % get max index of c-hat
            %[maxx index] = max(c_hat);
            
            %bin = d_codes(f,index);
            %texton_ind.data(f) = bin;
            
            texton_ind.data(f,:,1) = d_codes(f,:);
            texton_ind.data(f,:,2) = c_hat;
            
        end
        
    else
        for j = 1:batchSize:ndata
            lo = j;
            hi = min(j+batchSize-1,ndata);
            
            % get distances from each image feature to all dictionary codewords
            dist_mat = sp_dist2(features.data(lo:hi,:), dictionary);
            
            % sort the distances for each image feature
            [sorted_distances d_codes] = sort(dist_mat,2);
            
            % only care about nearest neighbors
            sorted_distances = sorted_distances(:,1:num_neighbors);
            d_codes = d_codes(:,1:num_neighbors);
            
            % normalize distances to 1
            normed_distances = normr(sorted_distances);
            
            % construct histogram
            tmp_hist = zeros(params.dictionarySize,1);
            
            for f=1:batchSize
                for k=1:num_neighbors
                    weight = normed_distances(f,k);
                    bin = d_codes(f,k);
                    tmp_hist(bin) = tmp_hist(bin) + weight;
                end
            end
            
            % ceiling magic
            tmp_hist = ceil(tmp_hist);
            
            % unroll histogram for SP code
            unrolled_hist = zeros(batchSize,1);
            
            iterator = 0;
            for b = 1:params.dictionarySize
                votes = tmp_hist(b);
                for v=1:votes
                    unrolled_hist(iterator+v) = b;
                end
                iterator = iterator + votes;
            end
            
            texton_ind.data(lo:hi,:) = unrolled_hist;
        end
    end
    
    H = hist(texton_ind.data(:,:,1), 1:params.dictionarySize);
    H_all = [H_all; H];
    
    %% save texton indices and histograms
    sp_make_dir(outFName);
    save(outFName, 'texton_ind');
    save(outFName2, 'H');
end

%% save histograms of all images in this directory in a single file
outFName = fullfile(dataBaseDir, sprintf('histograms_%d.mat', params.dictionarySize));
%save(outFName, 'H_all', '-ascii');


end
