function [ predicted_labels, actual_labels, accuracy, best_kernel_type ] = getBestModel( train_pyramids_set, ...
                                                                                         test_pyramids_set, ...
                                                                                         train_labels_set, ...
                                                                                         test_labels_set, ...
                                                                                         kernel_type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

accuracy = 0;
num_runs = size(train_pyramids_set,1);
num_classes = size(unique(train_labels_set{1}),1);

for k=1:size(kernel_type)
    mean_accuracy = 0;
    for run=1:num_runs
        
        train_pyramids = train_pyramids_set{run};
        test_pyramids = test_pyramids_set{run};
        
        train_labels = train_labels_set{run};
        test_labels = test_labels_set{run};
        
        fprintf('Starting run %d with kernel %d\n',run,kernel_type(k));
        
        options = sprintf('-q -s 1 -t %d', kernel_type(k));
        
        %do precomputed kernel
        if(kernel_type(k) == 4)
            test_pyramids = [(1:size(test_pyramids,1))' , hist_isect(test_pyramids,train_pyramids)];
            train_pyramids = [(1:size(train_pyramids,1))' , hist_isect(train_pyramids,train_pyramids)];
        end
        
        this_model = svmtrain(train_labels, sparse(train_pyramids), options);
        [this_predicted_label, ~, ~] = svmpredict(test_labels, sparse(test_pyramids), this_model);
        
        label_diffs = this_predicted_label - test_labels;
        
        run_accuracy = 0;
        
        class_start = 1;
        % calculate mean accuracy over classes
        for class=1:num_classes
            class_test_size = sum(test_labels==class);
            num_correct = sum(label_diffs(class_start:class_start+class_test_size-1)==0);
            
            run_accuracy = run_accuracy + double(num_correct)/double(class_test_size);
            
            class_start = class_start + class_test_size;
        end
        
        run_accuracy = run_accuracy/num_classes;
        
        mean_accuracy = mean_accuracy + run_accuracy;
    end
    
    mean_accuracy = mean_accuracy/num_runs;
    
    if (mean_accuracy > accuracy)
        best_kernel_type = kernel_type(k);
        accuracy = mean_accuracy
        predicted_labels = this_predicted_label;
        actual_labels = test_labels;
    end
end



end

