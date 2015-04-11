% Example of how to use the BuildPyramid function
% set image_dir and data_dir to your actual directories
image_dir = '../inputs';
data_dir = 'data';

total_images = 0;

% for other parameters, see BuildPyramid
dirs = dir(fullfile(image_dir, '/'));
dirs(1)=[];dirs(1)=[];
num_dirs = size(dirs,1);

filenames = cell(1);
pyramids = cell(1);

%suppress warning about erasemode within SP buildpyramid code
warning('off','MATLAB:hg:EraseModeIgnored');
for d = 1:num_dirs
    
    dirname = dirs(d).name;
    
    fnames = dir(fullfile(image_dir, dirname, '*.jpg'));
    num_files = size(fnames,1);
        
    filenames{d} = cell(num_files,4200);
    
    for i=1:num_files
        filenames{d}{i} = fnames(list(i)).name;
    end
    
    pyramids{d} = BuildPyramid(filenames{d}, fullfile(image_dir,dirname), fullfile(data_dir, dirname));
    
    total_images = total_images + num_files;
end
warning('on','MATLAB:hg:EraseModeIgnored');


%% param stuff
%number of runs for paramset
num_runs = 5;

%number of training instances
%num_train = [25, 50, 100];
num_train = [100];

%liblinear solver type
solver_type = [0:1:7];

%% get best model
getBestModel(pyramids, labels, num_runs, num_train, solver_type);