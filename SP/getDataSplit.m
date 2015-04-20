function [ train_filenames, test_filenames, train_labels, test_labels ] = getDataSplit( seed, num_train, dirs, image_dir )

total_images = 0;

num_dirs = size(dirs,1);
filenames = cell(cell(1));

train_filenames = cell(1,1);
test_filenames = cell(1,1);

train_labels = zeros(num_dirs*num_train,1);
test_labels = zeros(total_images-num_train*num_dirs,1);

for d = 1:size(dirs,1)
    
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



%get labels for test set
test_counter = 1;
for d = 1:size(dirs,1)
    test_size = size(filenames{d},1) - num_train;
    test_labels(test_counter:test_counter+test_size-1,:) = d;
    test_counter = test_counter + test_size;
end

train_filenames(1) = [];
test_filenames(1) = [];


end
