# CS 766 Scene Classification

Use Spatial Pyramid features and Support Vector Machines to classify images by their scene. Additionally, has the option to use Locality-constrained Linear Coding (LLC) for classification. A grid search can be used to obtain the best possible mean-class accuracy.

## Setup
The 'inputs' folder in the root directory of the repository should hold input data. Each subfolder within that directory will be treated as a class for scene classification. Inputs should be images in JPEG format. Each class subfolder should house the entire set of available images. These images are split into train and test sets randomly, porportional to a variable set by the user. 

Note: Initial generation of spatial pyramid features takes quite a long time. Subsequent re-executions of the code will run much faster, as the features are loaded from data files created by the first run. 

NOTE: The libsvm folder and its subdirectories should be added to the path before running the code.

### Parameters

Parameters for grid search and model generation are set in the "Parameter Setup" section in SP/main.m. 

* params.maxImageSize = 1000;
* params.gridSpacing = 8;
* params.patchSize = 16;
* params.dictionarySize = 200;
* params.numTextonImages = 100; /* Should always be set to training set size */
* params.pyramidLevels = 3;

The kernel for SVM classification can be set with the 'kernel_type' parameter.

### Execution

After setting the parameters in SP/main.m and importing images into the 'inputs' folder as specified above, the program can be run simply by executing main in the SP folder. Training results and accuracies will display in the terminal and will be saved out to a text file.

## Results
### Linear kernel vs Histogram-Intersection Kernel
The Histogram Intersection kernel maps each instance in a set to a feature space in which each feature is another instance in that set. In this sense, each instance is now represented as a sum of the entire data set. We implemented the histogram intersection kernel to determine if it may give better results.

We fixed the parameters to the following:

* params.maxImageSize = 1000;
* params.gridSpacing = 8;
* params.patchSize = 16;
* params.dictionarySize = 200;
* params.numTextonImages = 100;
* params.pyramidLevels = 3;

We ran the classification training and testing with both a standard linear kernel and with the Histogram Intersection kernel. In general, the use of the Histogram Intersection kernel provides a significant accuracy boost.  We also found that because the histogram interection kernel uses fewer features, it runs significantly faster than the linear kernel. Below we report the accuracies and confusion matricies for both methods. The confusion matrix is taken from  one random sampling of the entire set, and the accuracies are averaged over 5 random reselections of training and sets.

| Kernel Type                   | Mean Class Accuracy |
|-------------------------------|---------------------|
| Linear Kernel                 | 68.37%              |
| Histogram Intersection Kernel | 76.94%              |

Linear Kernel Confusion Matrix
![alt text](https://github.com/ronakrm/scene_classification/blob/master/SP/linear_confusion.png "Linear Kernel Matrix")

Histogram Intersection Kernel Confusion Matrix
![alt text](https://github.com/ronakrm/scene_classification/blob/master/SP/hist_isect_confusion.png "Histogram Intersection Confusion Matrix")

In this application, it is clear that using the histogram intersection kernel over the linear kernel  greatly improves performance and accuracy.

### Locality-constrained Linear Coding

Locality-constrained Linear Coding (LLC) is a simple coding scheme that uses locality constraints to project each feature descriptor into its local coordinate system. The projected coordinates are integrated by max pooling to generate the final representation. The purported benefit of this technique is speed - by using only the k nearest neighbors in the codebook for the feature's representation, we expect to reduce runtime against using a sum-pooling method over all codewords in the dictionary.  Our run times for LLC did prove to be significantly faster than vector quantization (VQ).

We fixed the parameters to the following:

* params.maxImageSize = 1000;
* params.gridSpacing = 8;
* params.patchSize = 16;
* params.dictionarySize = 200;
* params.numTextonImages = 100;
* params.pyramidLevels = 3;
* params.nearestNeighbor = 5;

Below we report the accuraciesfor both kernels using LLC. The confusion matrix is taken from  one random sampling of the entire set using the histogram intersection kernel, which has proven to be better in all cases. The accuracies are averaged over 5 random reselections of training and sets.

| Kernel Type                   | Mean Class Accuracy |
|-------------------------------|---------------------|
| Linear Kernel                 | 75.49%              |
| Histogram Intersection Kernel | 77.27%              |

LLC Histogram Intersection Kernel Confusion Matrix
![alt text](https://github.com/ronakrm/scene_classification/blob/master/SP/hist_isect_confusionLLC.png "LLC Histogram Intersection Confusion Matrix")

Comparing these results to the previous section, it is clear that LLC achieves significantly higher accuracy than VQ. Below we imiplement a grid search on spatial pyramid parameters, as there is some indication that better accuracies may be possible. [Wang et al.](http://www.ifp.illinois.edu/~jyang29/papers/CVPR10-LLC.pdf) recommend using a much larger dictionary size (e.g., 1024, 2048), for example. 

### Grid Search

Unfortunately due to time constraints we were unable to complete a grid search. All of the code was written and the grid search is ready to be run, but due to the size of files involved and the time complexity, it was unfeasible to complete.

A grid search would have been run over the parameters listed above to find the optimal set. Below are the values that we proposed searching over for each parameter.

* params.gridSpacing = 2,4,8;
* params.patchSize = 4,8,16;
* params.dictionarySize = 1024,2048,4096,8192,16384
* params.pyramidLevels = 3,4,5;
* nearestNeighbor = 3,5,10;

Results would have been averaged over three runs for each parameter configuration. The training set size was fixed to 100 images per class.

To run the grid search in its current form:

1. Set up file locations and subdirectories as described in the above Setup section.
2. Edit the parameter search space in main_grid.m
3. Run main_grid.m

The program will take many hours to complete, but as it runs all results from each parameter set are appended to a file "results.txt". Each line represents an average accuracy for a given set of parameters.

While we were unable to run this search, we expect there to be a trade-off between runtime of a parameter configuration and average accuracy, with a maximum at a specific location for each parameter. For example, as we increase the dictionary size, the time to calculate Histograms should increase significantly, but we expect that a richer dictionary should allow us to better classify test instances. We also suspect, however, that a very large dictionary may overfit the training images, and at some point cause a decrease in test set accuracy. This sort of trend is to be expected for all parameters, as image classification is a typical instantiation of a machine learning problem, and these hyperparameters tend to follow such a trend.
