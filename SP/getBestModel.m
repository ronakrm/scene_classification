function [ accuracy, best_num_train, best_solver_type ] = getBestModel( pyramids, num_runs, num_train, solver_type )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

accuracy = 0;

for a=1:size(num_train)
    for b=1:size(solver_type)
        
        mean_accuracy = 0;
        
        for run=1:num_runs
             [train_pyramids, train_labels, test_pyramids, test_labels] = createDataSplit(pyramids, num_train);
             options = sprintf('-s %d',solver_type(b));
             this_model = train(train_labels, sparse(train_pyramids), options);
            [this_predict_label, this_accuracy, this_prob_estimates] = predict(test_labels, test_pyramids, this_model);
            
            label_diffs = this_predict_label - test_labels;
                        
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
        
        mean_accuracy = mean_accuracy/size(num_runs);
        
        if (mean_accuracy > accuracy)
            best_num_train = a;
            best_solver_type = b;
            accuracy = mean_accuracy;
        end
        
    end
end


end

