% Main function for Assignment

%% param stuff

load_pyramids = false;

%number of training instances
%num_train = [25, 50, 100];
num_train = 100;

%libsvm kernel type; 4 is custom precompute, here hist_isect
kernel_type = [0;4]; %0 to 4

params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImages = num_train;
params.pyramidLevels = 3;
params.oldSift = false;
params.nearestNeighbor = 5;

% set image_dir and data_dir to your actual directories
image_dir = '../inputs';

% for other parameters, see BuildPyramid
dirs = dir(fullfile(image_dir, '/'));
dirs(1)=[];dirs(1)=[];
num_dirs = size(dirs,1);

%number of runs for paramset
seedsize = 5;

%%
train_pyramids_set = cell(seedsize,1);
test_pyramids_set = cell(seedsize,1);

train_labels_set = cell(seedsize,1);
test_labels_set = cell(seedsize,1);
    
%load pyramids from random seed
if load_pyramids
    

    
    for t=1:seedsize
        
        % get pyramids
        run_train_name = sprintf('train_pyramids_%d_%d.mat',t,params.dictionarySize);
        run_test_name = sprintf('test_pyramids_%d_%d.mat',t,params.dictionarySize);
        
        tmp_struct = load(run_train_name);
        train_pyramids_set{t} = tmp_struct.train_pyramids;
        tmp_struct = load(run_test_name);
        test_pyramids_set{t} = tmp_struct.test_pyramids;
        
        
        % get labels
        labels_train_name = sprintf('train_labels_%d_%d.mat',t,params.dictionarySize);
        labels_test_name = sprintf('test_labels_%d_%d.mat',t,params.dictionarySize);
        
        tmp_struct = load(labels_train_name);
        train_labels_set{t} = tmp_struct.train_labels;
        tmp_struct = load(labels_test_name);
        test_labels_set{t} = tmp_struct.test_labels;
        
        % get label names
        load('class_label_names.mat', 'class_names');
    end
    
else
    
    for seed=1:seedsize
        
        data_dir = strcat('data_LLC_',num2str(seed));
        
        trainmatfile = sprintf('train_pyramids_%d_%d.mat',seed,params.dictionarySize);
        testmatfile = sprintf('test_pyramids_%d_%d.mat',seed,params.dictionarySize);
        
        trainlabelfile = sprintf('train_labels_%d_%d.mat',seed,params.dictionarySize);
        testlabelfile = sprintf('test_labels_%d_%d.mat',seed,params.dictionarySize);
        
        seedsize = 1;
        total_images = 0;
        
        filenames = cell(cell(1));
        
        train_filenames = cell(1,1);
        test_filenames = cell(1,1);
        
        train_labels = zeros(num_dirs*num_train,1);
       
        for d = 1:num_dirs
            
            dirname = dirs(d).name;
            
            fnames = dir(fullfile(image_dir, dirname, '*.jpg'));
            num_files = ceil(size(fnames,1));
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
        
        test_labels = zeros(total_images-num_train*num_dirs,1);
        
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
        
        %train_pyramids = BuildPyramidLLC(train_filenames, fullfile(image_dir), fullfile(data_dir),params,1,1);
        pfig = sp_progress_bar('TRAIN');
        if(1)
            GenerateSiftDescriptors(train_filenames, fullfile(image_dir), fullfile(data_dir),params,1,pfig);
        end
        
        %Build dictionary with train
        CalculateDictionary(train_filenames,fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,1,pfig);
        
        BuildHistogramsLLC(train_filenames, fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,1,pfig);
        train_pyramids = CompilePyramidLLC(train_filenames, fullfile(data_dir), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,1,pfig);
        close(pfig);
        
        pfig = sp_progress_bar('TEST');
        if(1)
            GenerateSiftDescriptors( test_filenames, fullfile(image_dir), fullfile(data_dir),params,1,pfig);
        end
                
        BuildHistogramsLLC(test_filenames, fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,1,pfig);
        test_pyramids = CompilePyramidLLC(test_filenames, fullfile(data_dir), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,1,pfig);
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
        
        % save out class names
        class_names = dirs(:).name;
        save('class_label_names.mat', 'class_names');
        
        % make set
        train_pyramids_set{seed} = train_pyramids;
        test_pyramids_set{seed} = test_pyramids;
        
        train_labels_set{seed} = train_labels;
        test_labels_set{seed} = test_labels;
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
plot_confusion(dirs, actual_labels, predicted_labels);
