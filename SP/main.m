% Main function for Assignment
% set image_dir and data_dir to your actual directories
image_dir = '../inputs';
data_dir = 'data';

total_images = 0;

% for other parameters, see BuildPyramid
dirs = dir(fullfile(image_dir, '/'));
dirs(1)=[];dirs(1)=[];
num_dirs = size(dirs,1);

filenames = cell(cell(1));
%pyramids = cell(1);

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
    
    %pyramids{d} = BuildPyramid(filenames{d}, fullfile(image_dir,dirname), fullfile(data_dir, dirname));
    
    total_images = total_images + num_files;
    
    displayyy = sprintf('Completed building pyramids for dir %d',d);
    disp(displayyy);
end
warning('on','MATLAB:hg:EraseModeIgnored');


%% param stuff
%number of runs for paramset
num_runs = 2;

%number of training instances
%num_train = [25, 50, 100];
num_train = [100];

%libsvm kernel type; 4 is custom precompute, here hist_isect
kernel_type = [0;4]; %0 to 4

%% get best model
[ predicted_labels, actual_labels, accuracy, best_num_train] = getBestModel(pyramids', total_images, num_runs, num_train, kernel_type);

% make confusion matrix
c = confusionmat(actual_labels,predicted_labels);

cc = c;
for i=1:num_dirs
    cc(i,:) = c(i,:)/sum(c(i,:));
end

imshow(cc, 'InitialMagnification', 1000);