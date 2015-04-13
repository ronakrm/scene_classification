function [ train_pyramids, train_labels, test_pyramids, test_labels ] = createDataSplit( train_pyramidsC, test_pyramidsC )
%createDataSplit Summary of this function goes here
%   Detailed explanation goes here

classes = size(train_pyramidsC,1);

num_train = size(train_pyramidsC{1},1);

[class_test_sizes, ~] = cellfun(@size,test_pyramidsC, 'uni',false);
total_num_test = sum(cell2mat(class_test_sizes));

% here is where we split train/test
train_pyramids = zeros(classes*num_train,4200);
train_labels = zeros(classes*num_train,1);
test_pyramids = zeros(total_num_test,4200);
test_labels = zeros(total_num_test,1);

test_counter = 1;
for c=1:classes
    
    train_pyramids((c-1)*num_train+1:c*num_train,:) = train_pyramidsC{c};
    train_labels((c-1)*num_train+1:c*num_train) = c;
    
    test_size = class_test_sizes{c};
    
    test_pyramids(test_counter:test_counter+test_size-1,:) = test_pyramidsC{c};
    test_labels(test_counter:test_counter+test_size-1,:) = c;

    test_counter = test_counter + test_size;
end

end