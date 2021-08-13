# Live Image Labelling

Live Image Labelling is one of the features that capitalize on Tensorflow, Google's Machine Learning Framework that has been designed to develop and serve models even on Low-Ended Devices like Smartphones. To make this possible we are capitalizing on the capability of Transfer Learning to develop the Models real quick and to get an appreciable Performance Metric even in the lacking support for high-ended devices.

## What is Transfer Learning?

The idea and methodology behind Transfer Learning are quite simple: To use an existing pre-trained Neural Network’s knowledge on a new dataset which it has never seen before.

The idea behind Transfer Learning started with AlexNet back in 2012 where it won the ImageNet Large Scale Visual recognition challenge. After AlexNet, many other pre-trained models came into the scene which outperformed AlexNet in terms of accuracy on ImageNet Dataset.

Researchers conceptualized an idea to utilize these pre-trained models to train and develop new classifiers on a dataset that the pre-trained model has never encountered before. This technique was used to harness and transfer the learning of a previous model to a new dataset.

And surprisingly, Transfer Learning makes it quite easy for Researchers and Machine Learning Developers to train models on new datasets by just changing and modifying the last layer according to their needs.

## Usage of Transfer Learning

We are making use of the SSD Mobilenet Model from Keras and set the Trainable Layers to False so that we don’t train them from our side. After successfully modelling the Data, we can convert them to a Tflite Model that can be served using a Tflite Plugin.

The Tflite Plugin will be induced as a Dev Dependency that will be used to integrate our neural network with the app. The Tflite Plugin will be used with a `loadModel()` function which would load the Image and then use the `runModelOnFrame()` function to take the Camera Stream Input and generate the inferences henceforth.

## Screenshot

![image](https://i.imgur.com/uQ4v1nB.jpg)

## Footnotes

- [A Gentle Introduction to Transfer Learning for Deep Learning](https://machinelearningmastery.com/transfer-learning-for-deep-learning/)
- [ML for Mobile and Edge Devices](https://www.tensorflow.org/lite/guide)
- [tflite Flutter Package](https://pub.dev/packages/tflite)
