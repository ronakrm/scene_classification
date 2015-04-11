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
Here is why why one would wish to use the hist kern....

We fixed the parameters to TODO and ran the classification training and testing both with and without using the Histogram Intersection Kernel. In general, the use of the kernel provides a significant accuracy boost. Below we report the accuracies and confusion matricies for both methods, averaged over 5 random reselections of training sets:
  TODO confusionHIST
  TODO confusionNONHIST

### Kernel Methods

confusion matrix/accuracy of various kernel methods (linear, quadratic, rbf, isect-hist)
  
### Training Set Size
  We fixed the parameters to TODO and varied the training set size from the set [asdf asdf asdfas].
  
  TODO plot of accuracy vs training set size
  
  comments on overfitting here
  
### Grid Search
