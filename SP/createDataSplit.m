function [ train_pyramids, train_labels, test_pyramids, test_labels ] = createDataSplit( pyramids, num_train )
%createDataSplit Summary of this function goes here
%   Detailed explanation goes here


% here is where we split train/test
train_pyramids = zeros(num_dirs*num_train,4200);
train_labels = zeros(num_dirs*num_train,1);
test_pyramids = zeros(total_images - num_dirs*num_train,4200);
test_labels = zeros(total_images - num_dirs*num_train,1);

test_counter = 1;
for c=1:size(pyramids,1)
    num_images = size(pyramids{c},1);
    test_size = num_images - num_train;
    list = randperm(num_images);
    for i=1:num_images
        if (i <= num_train)
            train_pyramids((c-1)*num_train+1:c*num_train,:) = pyramids{c}{list(i)};
            train_labels((c-1)*num_train+1:c*num_train) = c;
        else
            test_pyramids(test_counter:test_counter+test_size-1,:) = pyramids{c}{list(i)};
            test_labels(test_counter:test_counter+test_size-1,:) = c;
        end
    end

    test_counter = test_counter + test_size;
end

end