% Main function for Assignment

%% param stuff

load_pyramids = false;

%number of training instances
%num_train = [25, 50, 100];
num_train = 100;

%libsvm kernel type; 4 is custom precompute, here hist_isect
kernel_type = [0,4]; %0 to 4

params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImages = 50;
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
        
        train_pyramids_set{t} = load(run_train_name).train_pyramids;
        test_pyramids_set{t} = load(run_test_name).test_pyramids;
        
        
        % get labels
        labels_train_name = sprintf('train_labels_%d.mat',t);
        labels_test_name = sprintf('test_labels_%d.mat',t);
        
        train_labels_set{t} = load(labels_train_name).train_labels;
        test_labels_set{t} = load(labels_test_name).test_labels;
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
        
        train_pyramids_set = cell(num_runs,1);
        test_pyramids_set = cell(num_runs,1);
        
        train_labels_set = cell(num_runs,1);
        test_labels_set = cell(num_runs,1);
        
        train_pyramidsC = cell(1);
        test_pyramidsC = cell(1);
        
        %suppress warning about erasemode within SP buildpyramid code
        warning('off','MATLAB:hg:EraseModeIgnored');
        for d = 1:num_dirs
            
            dirname = dirs(d).name;
            
            fnames = dir(fullfile(image_dir, dirname, '*.jpg'));
            num_files = size(fnames,1);
            
            filenames{d} = cell(num_files,1);
            
            for i=1:num_files
                filenames{d}{i} = fnames(i).name;
            end
            
            rng(seed);
            list = randperm(num_files);
            
            train_filenames = filenames{d}(list(1:num_train));
            test_filenames = filenames{d}(list(num_train+1:num_files));
            
            train_pyramidsC{d} = BuildPyramid(train_filenames, fullfile(image_dir,dirname), fullfile(data_dir, dirname),params,0,0);
            
            pfig = sp_progress_bar('Building Histograms and Spatial Pyramids for Test');
            BuildHistograms(test_filenames, fullfile(image_dir,dirname), fullfile(data_dir, dirname),'_sift.mat',params,0,pfig);
            test_pyramidsC{d} = CompilePyramid(test_filenames, fullfile(data_dir, dirname), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,0,pfig);
            
            displayyy = sprintf('Completed building pyramids for dir %d',d);
            disp(displayyy);
        end
        
        warning('on','MATLAB:hg:EraseModeIgnored');
        
        [train_pyramids, train_labels, test_pyramids, test_labels] = createDataSplit(train_pyramidsC, test_pyramidsC);
        
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
% [ predicted_labels, actual_labels, accuracy, best_kernel_type] = getBestModel( ...
%                     train_pyramids_set, ...
%                     test_pyramids_set, ...
%                     train_labels_set, ...
%                     test_labels_set, ...
%                     kernel_type ...
%                 );
%
% % make confusion matrix
% c = confusionmat(actual_labels,predicted_labels);
%
% cc = c;
% for i=1:num_dirs
%     cc(i,:) = c(i,:)/sum(c(i,:));
% end
%
% imshow(cc, 'InitialMagnification', 1000);