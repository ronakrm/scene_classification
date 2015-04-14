% Main function for Assignment

%% param stuff

load_pyramids = false;

%number of training instances
%num_train = [25, 50, 100];
num_train = 100;

%libsvm kernel type; 4 is custom precompute, here hist_isect
kernel_type = [4]; %0 to 4

params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImages = num_train;
params.pyramidLevels = 3;
params.oldSift = false;


%%

%load pyramids from random seed
if load_pyramids
    
    %number of runs for paramset
    num_runs = 5;
    
    train_pyramids_set = cell(num_runs,1);
    test_pyramids_set = cell(num_runs,1);
    
    train_labels_set = cell(num_runs,1);
    test_labels_set = cell(num_runs,1);
    
    for t=1:num_runs
        run_train_name = sprintf('train_pyramids_%d.mat',t);
        run_test_name = sprintf('test_pyramids_%d.mat',t);
        
        tmp_struct = load(run_train_name);
        train_pyramids_set{t} = tmp_struct.train_pyramids;
        tmp_struct = load(run_test_name);
        test_pyramids_set{t} = tmp_struct.test_pyramids;
        
        
        % get labels
        labels_train_name = sprintf('train_labels_%d.mat',t);
        labels_test_name = sprintf('test_labels_%d.mat',t);
        
        tmp_struct = load(labels_train_name);
        train_labels_set{t} = tmp_struct.train_labels;
        tmp_struct = load(labels_test_name);
        test_labels_set{t} = tmp_struct.test_labels;
    end
    
else
    
    % set image_dir and data_dir to your actual directories
    image_dir = '../inputs';
    data_dir = 'data';
    
    seedsize = 5;
    
    for seed=1:seedsize
        
        trainmatfile = sprintf('train_pyramids_%d.mat',seed);
        testmatfile = sprintf('test_pyramids_%d.mat',seed);
        
        trainlabelfile = sprintf('train_labels_%d.mat',seed);
        testlabelfile = sprintf('test_labels_%d.mat',seed);
                
        num_runs = 1;
        total_images = 0;
        
        % for other parameters, see BuildPyramid
        dirs = dir(fullfile(image_dir, '/'));
        dirs(1)=[];dirs(1)=[];
        num_dirs = size(dirs,1);
        
        filenames = cell(cell(1));
        
        train_filenames = cell(1,1);
        test_filenames = cell(1,1);
        
        train_labels = zeros(num_dirs*num_train,1);
                
        train_pyramids_set = cell(num_runs,1);
        test_pyramids_set = cell(num_runs,1);
        
        train_labels_set = cell(num_runs,1);
        test_labels_set = cell(num_runs,1);
        
        for d = 1:num_dirs
            
            dirname = dirs(d).name;
            
            fnames = dir(fullfile(image_dir, dirname, '*.jpg'));
            num_files = size(fnames,1);
            total_images = total_images + num_files;
            test_size = num_files-num_train;
            
            rng(seed);
            list = randperm(num_files);            
            
            filenames{d} = cell(num_files,1);
            
            for i=1:num_files
                filenames{d}{i} = strcat(dirname, filesep, fnames(i).name);  
            end
            
            train_filenames =  [train_filenames; filenames{d}(list(1:num_train))];
            test_filenames = [test_filenames; filenames{d}(list(num_train+1:num_files))];
            
            train_labels((d-1)*num_train+1:d*num_train) = d;

        end
        
        test_labels = zeros(total_images,1);
        
        %get labels for test set
        test_counter = 1;
        for d = 1:num_dirs
            test_size = size(filenames{d},1) - num_train;
            test_labels(test_counter:test_counter+test_size-1,:) = d;
            test_counter = test_counter + test_size;
        end
        
        train_filenames(1) = [];
        test_filenames(1) = [];
        
        %suppress warning about erasemode within SP buildpyramid code
        warning('off','MATLAB:hg:EraseModeIgnored');
        train_pyramids = BuildPyramid(train_filenames, fullfile(image_dir), fullfile(data_dir),params,1,1);
        
        pfig = sp_progress_bar('Building Histograms and Spatial Pyramids for Test');
        BuildHistograms(test_filenames, fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,1,pfig);
        test_pyramids = CompilePyramid(test_filenames, fullfile(data_dir), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,1,pfig);
        close(pfig);
        
        displayyy = sprintf('Completed building pyramids for dir %d',d);
        disp(displayyy);
        warning('on','MATLAB:hg:EraseModeIgnored');
        
       % [train_labels, test_labels] = getLabels(train_pyramids, test_pyramids);
        
        % save out train and test pyramids mat files
        save(trainmatfile, 'train_pyramids');
        save(testmatfile, 'test_pyramids');
        
        % save out train and test labels mat files
        save(trainlabelfile, 'train_labels');
        save(testlabelfile, 'test_labels');
        
        % make set
        train_pyramids_set{1} = train_pyramids;
        test_pyramids_set{1} = test_pyramids;
        
        train_labels_set{1} = train_labels;
        test_labels_set{1} = test_labels;
    end
end

%% get best model
[ predicted_labels, actual_labels, accuracy, best_kernel_type] = getBestModel( ...
    train_pyramids_set, ...
    test_pyramids_set, ...
    train_labels_set, ...
    test_labels_set, ...
    kernel_type ...
    );

% make confusion matrix
c = confusionmat(actual_labels,predicted_labels);

cc = c;
for i=1:size(unique(train_labels_set{1}),1)
    cc(i,:) = c(i,:)/sum(c(i,:));
end

imshow(cc, 'InitialMagnification', 1000);