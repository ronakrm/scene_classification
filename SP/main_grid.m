% Main function for Assignment

%% param stuff

load_pyramids = false;

%number of training instances
num_train = 100;

params.maxImageSize = 1000;
params.numTextonImages = num_train;
params.oldSift = false;

% set image_dir and data_dir to your actual directories
image_dir = '../inputs';

dirs = dir(fullfile(image_dir, '/'));
dirs(1)=[];dirs(1)=[];
num_dirs = size(dirs,1);

%number of runs for paramset, also seed for random split of train/test
num_runs = 1;

%% PARAMETERS FOR GRID SEARCH
gridSpacing = [2;4;8];
patchSize = [4;8;16];
dictionarySize = [1024;2048;4096;8192;16384];
pyramidLevels = [3;4;5];
nearestNeighbor = [3;5;10];

%% THE SEARCH
for gspace = 1:size(gridSpacing,1)
    params.gridSpacing = gridSpacing(gspace);
    for psize = 1:size(patchSize,1)
        params.patchSize = patchSize(psize);
        skipSift = 0;
        for dsize = 1:size(dictionarySize,1)
            params.dictionarySize = dictionarySize(dsize);
            skipDict = 0;
            for n = 1:size(nearestNeighbor,1)
                params.nearestNeighbor = nearestNeighbor(n);
                skipHist = 0;
                for plevels = 1:size(pyramidLevels,1)
                    params.pyramidLevels = pyramidLevels(plevels);
                    
                    
                    % stuff here
                    mean_accuracy = 0;
                    
                    for run = 1:num_runs
                        
                        fprintf('Starting run %d with %d patch size\n',run,patchSize(psize));
                        
                        % split test and train, get labels
                        [ train_filenames, test_filenames, train_labels, test_labels ] = getDataSplit(run, num_train, dirs, image_dir);
                        
                        data_dir = strcat('data_LLC_',num2str(run));
                        
                        % build pyramids
                        [train_pyramids, test_pyramids] = getPyramids(train_filenames, test_filenames, params, image_dir, data_dir, skipSift, skipDict, skipHist);
                        skipHist = 1;
                        skipDict = 1;
                        skipSift = 1;
                        
                        options = sprintf('-q -s 1 -t 4');
                        
                        %do precomputed kernel (hist isect)
                        test_pyramids = [(1:size(test_pyramids,1))' , hist_isect(test_pyramids,train_pyramids)];
                        train_pyramids = [(1:size(train_pyramids,1))' , hist_isect(train_pyramids,train_pyramids)];
                        
                        this_model = svmtrain(train_labels, sparse(train_pyramids), options);
                        [this_predicted_label, ~, ~] = svmpredict(test_labels, sparse(test_pyramids), this_model);
                        
                        label_diffs = this_predicted_label - test_labels;
                        
                        run_accuracy = 0;
                        
                        class_start = 1;
                        % calculate mean accuracy over classes
                        for class=1:num_dirs
                            class_test_size = sum(test_labels==class);
                            num_correct = sum(label_diffs(class_start:class_start+class_test_size-1)==0);
                            
                            run_accuracy = run_accuracy + double(num_correct)/double(class_test_size);
                            
                            class_start = class_start + class_test_size;
                        end
                        
                        run_accuracy = run_accuracy/num_dirs;
                        
                        mean_accuracy = mean_accuracy + run_accuracy;
                    end
                    
                    mean_accuracy = mean_accuracy/num_runs;
                    
                    % dump params and acc to file
                    result = sprintf('%d,%d,%d,%d,%d,%f\n',params.gridSpacing,params.patchSize,params.dictionarySize,params.pyramidLevels,params.nearestNeighbor,mean_accuracy);
                    
                    fid = fopen('results.txt', 'a+');
                    fprintf(fid, result);
                    fclose(fid);
                    
                    disp(result);
                end
            end
        end
    end
end
