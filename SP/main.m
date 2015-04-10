% Example of how to use the BuildPyramid function
% set image_dir and data_dir to your actual directories
image_dir = '../inputs';
data_dir = 'data';

num_train = 100;

% for other parameters, see BuildPyramid
dirs = dir(fullfile(image_dir, '/'));
dirs(1)=[];dirs(1)=[];
num_dirs = size(dirs,1);
trainset = cell(num_dirs,1);
testset = cell(num_dirs,1);
for d = 1:num_dirs
    fnames = dir(fullfile(image_dir, dirs(d).name, '*.jpg'));
    num_files = size(fnames,1);
    trainset{d} = cell(num_train,1);
    testset{d} = cell(num_files - num_train,1);
    
    % here is where we split train/test
    list = randperm(num_files);
    
    for i=1:num_files
        if (i <= num_train)
            trainset{d}{i} = fnames(list(i)).name;
        else
            testset{d}{i-num_train} = fnames(list(i)).name;
        end
    end
end

pyramids = zeros(num_train*num_dirs, 4200);
helpronak = zeros(num_train*num_dirs, 1);

%suppress warning about erasemode within SP buildpyramid code

warning('off','MATLAB:hg:EraseModeIgnored');

for d = 1:num_dirs
    pyramids((d-1)*num_train+1:(d*num_train),:) = BuildPyramid(trainset{d},fullfile(image_dir,dirs(d).name),fullfile(data_dir, num2str(d)));
    helpronak((d-1)*num_train+1:(d*num_train)) = d;
end
warning('on','MATLAB:hg:EraseModeIgnored');
% return pyramid descriptors for all files in filenames
%pyramid_all = BuildPyramid(filenames,image_dir,data_dir);

model = train(helpronak, pyramids);
