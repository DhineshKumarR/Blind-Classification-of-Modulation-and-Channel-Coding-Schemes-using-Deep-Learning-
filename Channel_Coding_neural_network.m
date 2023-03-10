% -------------------------------------------------------------------------
%% classification ( Neural Network Algorithm)
%%-------------------------------------------------------------------------
clear all
%% load input data%%-------------------------------------------------------
load('traindata_dc2_7dB_10000.mat');
%%-------------------------------------------------------------------------
%       numFeatures = size(meas, 2); % Total number of features - should be 4
meas = traindata_dc2_7dB_10000([1:16],:);
meas = meas';
numFeatures =  traindata_dc2_7dB_10000([1:16],:);
numFeatures = size(numFeatures, 1);
[IDs] =traindata_dc2_7dB_10000(19,:); % Convert character labels to unique IDs
numClasses = max(IDs); % Get total number of possible classes
M = traindata_dc2_7dB_10000([1:16],:);
M = size(M, 2); % Number of examples
Y = full(sparse(1 : M, IDs.', 1, M, numClasses)); % Create an output
%%----------neural network------------------------------------
net = NeuralNet2([numFeatures 256 256 numClasses]); % Create Neural Network object
% 16 input layer neurons, one hidden layer with 16 neurons and 4 output layer neuron
%%-------------------------------------------------------------------------
N = 20000;                   % Do 5000 iterations of Stochastic Gradient Descent
% Customize Neural Network 
net.LearningRate = 0.1;         % Learning rate is set to 0.1
net.RegularizationType = 'L2';  % Regularization is L2
net.RegularizationRate = 0.001; % Regularization rate is 0.001
net.ActivationFunction = 'tanh'; % sigmoid hidden activation function
net.BatchSize = 100;
perf = net.train(meas, Y, N);  % Train the Neural Network
Yraw = net.sim(meas);         % Use trained object on original examples
[~, Ypred] = max(Yraw, [], 2); % Determine which class has the largest response per example
figure(1)
plot(1:N, perf);            % Plot cost function per iteration
xlabel('Epoch'); ylabel('Error');
title('Error vs Epoch (Model optimisation)');
% Display results
disp('Training Examples and expected labels'); 
% display(meas); 
% disp('Labelled'); 
Labelled = [((IDs)')];
% disp('Predicted outputs');
Predicted_outputs = [(Ypred)];
Result = table(Labelled,Predicted_outputs)
disp('class = 1 >> Channel Coding with BPSK modulation,class = 2 >> Channel Coding with QPSK modulation,class = 3 >> UnCoded with BPSK modulation,class = 4 >> UnCoded with QPSK modulation');
disp('Classification accuracy: ');
disp(100 * sum((IDs)' == Ypred) / M);
% err = testdata_c_7dB(21,:);
% err = err';