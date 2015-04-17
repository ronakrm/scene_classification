# CS 766 Scene Classification

Use Spatial Pyramid features and Support Vector Machines to classify images by their scene. Additionally, has the option to use Locality-constrained Linear Coding (LLC) for classification. A grid search can be used to obtain the best possible mean-class accuracy.

## Setup
The 'inputs' folder in the root directory of the repository should hold input data. Each subfolder within that directory will be treated as a class for scene classification. Inputs should be images in JPEG format. Each class subfolder should house the entire set of available images. These images are split into train and test sets randomly, porportional to a variable set by the user. 

Note: Initial generation of spatial pyramid features takes quite a long time. Subsequent re-executions of the code will run much faster, as the features are loaded from data files created by the first run. 

## Parameter Setup

Parameters for grid search and model generation are set in the "Parameter Setup" section in SP/main.m

*param1:deatils
*param2:details

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

We ran the classification training and testing with both a standard linear kernel and with the Histogram Intersection kernel. In general, the use of the Histogram Intersection kernel provides a significant accuracy boost.  We also found that because the histogram interection kernel uses fewer features, it runs significantly faster than the linear kernel. Below we report the accuracies and confusion matricies for both methods. The confusion matrix is taken from  one  random sampling of the entire set, and the accuracies are averaged over 5 random reselections of trainingand sets.

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

We ran the classification training and testing with both a standard linear kernel and with the Histogram Intersection kernel. In general, the use of the Histogram Intersection kernel provides a significant accuracy boost.  We also found that because the histogram interection kernel uses fewer features, it runs significantly faster than the linear kernel. Below we report the accuracies and confusion matricies for both methods. The confusion matrix is taken from  one  random sampling of the entire set, and the accuracies are averaged over 5 random reselections of trainingand sets.

| Kernel Type                   | Mean Class Accuracy |
|-------------------------------|---------------------|
| Linear Kernel                 | 68.37%              |
| Histogram Intersection Kernel | 76.94%              |

LLC Linear Kernel Confusion Matrix
![alt text](https://github.com/ronakrm/scene_classification/blob/master/SP/linear_confusionLLC.png "LLC Linear Kernel Matrix")

LLC Histogram Intersection Kernel Confusion Matrix
![alt text](https://github.com/ronakrm/scene_classification/blob/master/SP/hist_isect_confusionLLC.png "LLC Histogram Intersection Confusion Matrix")

Comparing these results to the previous section, it is clear that LLC ______ . 

### Kernel Methods

confusion matrix/accuracy of various kernel methods (linear, quadratic, rbf, isect-hist)
  
### Training Set Size
  We fixed the parameters to TODO and varied the training set size from the set [asdf asdf asdfas].
  
  TODO plot of accuracy vs training set size
  
  comments on overfitting here
  
### Grid Search
