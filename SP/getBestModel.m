function [ predicted_labels, actual_labels, accuracy, ...
    best_num_train, best_kernel_type ] = getBestModel( pyramids, total_images, ...
    num_runs, num_train_ops, kernel_type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

accuracy = 0;

for a=1:size(num_train_ops)
    num_train = num_train_ops(a);
    for k=1:size(kernel_type)
        mean_accuracy = 0;
        for run=1:num_runs
            
            disp(sprintf('Starting run %d with kernel %d',run,kernel_type(k)));
            
            [train_pyramids, train_labels, test_pyramids, test_labels] = createDataSplit(pyramids, total_images, num_train);
            
            options = sprintf('-q -s 1 -t %d', kernel_type(k));
            
            %do precomputed kernel
            if(kernel_type(k) == 4)
                test_pyramids = [(1:total_images-num_train*size(pyramids,1))' , hist_isect(test_pyramids,train_pyramids)];
                train_pyramids = [(1:num_train*size(pyramids,1))' , hist_isect(train_pyramids,train_pyramids)];
            end
            
            this_model = svmtrain(train_labels, sparse(train_pyramids), options);
            [this_predicted_label, this_accuracy, this_prob_estimates] = svmpredict(test_labels, sparse(test_pyramids), this_model);
            
            label_diffs = this_predicted_label - test_labels;
            
            run_accuracy = 0;
            
            class_start = 1;
            % calculate mean accuracy over classes
            for class=1:size(pyramids,1)
                class_test_size = size(pyramids{class},1)-num_train;
                num_correct = sum(label_diffs(class_start:class_start+class_test_size-1)==0);
                
                run_accuracy = run_accuracy + double(num_correct)/double(class_test_size);
                
                class_start = class_start + class_test_size;
            end
            
            run_accuracy = run_accuracy/size(pyramids,1);
            
            mean_accuracy = mean_accuracy + run_accuracy;
        end
        
        mean_accuracy = mean_accuracy/num_runs;
        
        if (mean_accuracy > accuracy)
            best_num_train = num_train(a);
            best_kernel_type = kernel_type(k);
            accuracy = mean_accuracy
            predicted_labels = this_predicted_label;
            actual_labels = test_labels;
        end
    end
end


end

