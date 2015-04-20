function [ train_pyramids, test_pyramids ] = getPyramids( train_filenames, test_filenames, params, image_dir, data_dir, skipSift, skipDict, skipHist )

%suppress warning about erasemode within SP buildpyramid code
warning('off','MATLAB:hg:EraseModeIgnored');

pfig = sp_progress_bar('TRAIN');

GenerateSiftDescriptors(train_filenames, fullfile(image_dir), fullfile(data_dir),params,skipSift,pfig);

%Build dictionary with train
CalculateDictionary(train_filenames,fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,skipDict,pfig);

BuildHistogramsLLC(train_filenames, fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,skipHist,pfig);
train_pyramids = CompilePyramidLLC(train_filenames, fullfile(data_dir), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,skipHist,pfig);
close(pfig);


pfig = sp_progress_bar('TEST');
GenerateSiftDescriptors( test_filenames, fullfile(image_dir), fullfile(data_dir),params,skipSift,pfig);

BuildHistogramsLLC(test_filenames, fullfile(image_dir), fullfile(data_dir),'_sift.mat',params,skipHist,pfig);
test_pyramids = CompilePyramidLLC(test_filenames, fullfile(data_dir), sprintf('_texton_ind_%d.mat',params.dictionarySize),params,0,pfig);
close(pfig);


% back on warnings
warning('on','MATLAB:hg:EraseModeIgnored');

end
