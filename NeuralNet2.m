%%------------------------------------------------------------------------------------------------------------------
%% Neural Network
%%------------------------------------------------------------------------------------------------------------------
classdef NeuralNet2 < handle

    properties (Access = public)
        LearningRate % The learning rate (positive number)
        ActivationFunction % The desired activation function (string)
        OutputActivationFunction % The desired output activation function (string)
        RegularizationType % The type of regularization (string)
        RegularizationRate % The regularization rate (non-negative number)
        BatchSize % The size of the batch per iteration (positive integer number)
    end

    properties (Access = private)
        inputSize % Single value denoting how many neurons are in the input layer
        hiddenSizes % Vector denoting how many neurons per hidden layer
        outputSize % Single value denoting how many neurons are in the output layer
        weights % The weights of the neural network per layer
    end

    methods
        function this = NeuralNet2(layerSizes)
         

           % default params
            this.LearningRate = 0.03;
            this.ActivationFunction = 'Tanh';
            this.OutputActivationFunction = [];
            this.RegularizationType = 'None';
            this.RegularizationRate = 0;
            this.BatchSize = 10;

            assert(numel(layerSizes) >= 2, 'Total number of layers should be at least 2');

            % network structure (fully-connected feed-forward)
            % Obtain input layer neuron size
            this.inputSize = layerSizes(1);

            % Obtain the hidden layer neuron sizes
            if numel(layerSizes ~= 2)
                this.hiddenSizes = layerSizes(2:end-1);
            else
                this.hiddenSizes = 0;
            end

            % Obtain the output layer neuron size
            this.outputSize = layerSizes(end);

            % Initialize matrices relating between the ith layer
            % and (i+1)th layer
            this.weights = cell(1, numel(layerSizes) - 1);
            for i = 1 : numel(layerSizes) - 1
                this.weights{i} = zeros(layerSizes(i) + 1, layerSizes(i + 1));
            end

            % Initialize weights
            init(this);
        end
        function configure(this, X, Y)
            % check correct sizes
            [xrows,xcols] = size(X);
            [yrows,ycols] = size(Y);
            assert(xrows == yrows);
            assert(xcols == this.inputSize);
            assert(ycols == this.outputSize);

            % min/max of inputs/outputs
            inMin = min(X);
            inMax = max(X);
            outMin = min(Y);
            outMax = max(Y);
        end

        function init(this)
            % init  Initialize the Neural Network Weights

            for ii = 1 : numel(this.weights)
                num = numel(this.weights{ii});
                % Kaiming He et al. initialization strategy
                this.weights{ii}(:) = 2.0 * randn(num, 1) / ...
                    sqrt(size(this.weights{ii}, 1));
            end
        end

        function perf = train(this, X, Y, numIter)
            % train  Perform neural network training with Stochastic Gradient Descent (SGD)
          
            if nargin < 4, numIter = 1; end

            % Ensure correct sizes
            assert(size(X, 1) == size(Y, 1), ['Total number of examples ' ...
                   'the inputs and outputs should match'])

            % Ensure regularization rate and batch size is proper
            assert(this.BatchSize >= 1, 'Batch size should be 1 or more');
            assert(this.RegularizationRate >= 0, ['Regularization rate ' ...
                   'should be 0 or larger']);

            % Check if we have specified the right regularization type
            regType = this.RegularizationType;
            assert(any(strcmpi(regType, {'l1', 'l2', 'none'})), ...
                   ['Ensure that you choose one of ''l1'', ''l2'' or '...
                   '''none'' for the regularization type']);

            % Ensure number of iterations is strictly positive
            assert(numIter >= 1, 'Number of iterations should be positive');

            % Initialize cost function array
            perf = zeros(1, numIter);

            % Total number of examples
            N = size(X, 1);

            % Total number of applicable layers
            L = numel(this.weights);

            % Get batch size
            % Remove decimal places in case of improper input
            B = floor(this.BatchSize);

            % Safely catch if batch size is larger than total number
            % of examples
            if B > N
                B = N;
            end

            % Cell array to store input and outputs of each neuron
            sNeuron = cell(1, L);

            % First cell array is for the initial
            xNeuron = cell(1, L + 1);

            % Cell array for storing the sensitivities
            delta = cell(1, L);

            % For L1 regularization
            if strcmpi(regType, 'l1')
                % This represents the total L1 penalty that each
                % weight could have received up to current point
                uk = 0;

                % Total penalty for each weight that was received up to
                % current point
                qk = cell(1, L);
                for ii = 1 : L
                    qk{ii} = zeros(size(this.weights{ii}));
                end
            end

            % Get activation function for the hidden layer
            fcn = getActivationFunction(this.ActivationFunction);

            % Get derivative of activation function for the hidden layer
            dfcn = getDerivativeActivationFunction(this.ActivationFunction);

            % Do the same for the output layer
            if isempty(this.OutputActivationFunction)
                fcnOut = fcn;
                dfcnOut = dfcn;
            else
                fcnOut = getActivationFunction(this.OutputActivationFunction);
                dfcnOut = getDerivativeActivationFunction(this.OutputActivationFunction);
            end

            % For each iteration...
            for ii = 1 : numIter
                % If the batch size is equal to the total number of examples
                % don't bother with random selection as this will be a full
                % batch gradient descent
                if N == B
                    ind = 1 : N;
                else
                    % Randomly select examples corresponding to the batch size
                    % if the batch size is not equal to the number of examples
                    ind = randperm(N);
                    ind = ind(1 : B);
                end

                % Select out the training example features and expected outputs
                IN = X(ind, :);
                OUT = Y(ind, :);

                % Initialize input layer
                xNeuron{1} = [IN ones(B, 1)];

                %%% Perform forward propagation
                % Make sure you save the inputs and outputs into each neuron
                % at the hidden and output layers
                for jj = 1 : L
                    % Compute inputs into next layer
                    sNeuron{jj} = xNeuron{jj} * this.weights{jj};

                    % Compute outputs of this layer
                    if jj == L
                        xNeuron{jj + 1} = fcnOut(sNeuron{jj});
                    else
                        xNeuron{jj + 1} = [fcn(sNeuron{jj}) ones(B, 1)];
                    end
                end

                %%% Perform backpropagation

                % Compute sensitivities for output layer
                delta{end} = (xNeuron{end} - OUT) .* dfcnOut(sNeuron{end});

                % Compute the sensitivities for the rest of the layers
                for jj = L - 1 : -1 : 1
                    delta{jj} = dfcn(sNeuron{jj}) .* ...
                        (delta{jj + 1}*(this.weights{jj + 1}(1 : end - 1, :)).');
                end

                %%% Compute weight updates
                alpha = this.LearningRate;
                lambda = this.RegularizationRate;
                for jj = 1 : L
                    % Obtain the outputs and sensitivities for each
                    % affected layer
                    XX = xNeuron{jj};
                    D = delta{jj};

                    % Calculate batch weight update
                    weight_update = (1 / B) * (XX.') * D;

                    % Apply L2 regularization if required
                    if strcmpi(regType, 'l2')
                        weight_update(1 : end-1, :) = weight_update(1 : end - 1, :) + ...
                            (lambda/B)*this.weights{jj}(1 : end - 1, :);
                    end

                    % Compute the final update
                    this.weights{jj} = this.weights{jj} - alpha * weight_update;
                end

                % Apply L1 regularization if required
                if strcmpi(regType, 'l1')
                    % Step #1 - Accumulate total L1 penalty that each
                    % weight could have received up to this point
                    uk = uk + (alpha * lambda / B);

                    % Step #2
                    % Using the updated weights, now apply the penalties
                    for jj = 1 : L
                        % 2a - Save previous weights and penalties
                        % Make sure to remove bias terms
                        z = this.weights{jj}(1 : end - 1,:);
                        q = qk{jj}(1 : end - 1,:);

                        % 2b - Using the previous weights, find the weights
                        % that are positive and negative
                        w = z;
                        indwp = w > 0;
                        indwn = w < 0;

                        % 2c - Perform the update on each condition
                        % individually
                        w(indwp) = max(0, w(indwp) - (uk + q(indwp)));
                        w(indwn) = min(0, w(indwn) + (uk - q(indwn)));

                        % 2d - Update the actual penalties
                        qk{jj}(1:end-1,:) = q + (w - z);

                        % Don't forget to update the actual weights!
                        this.weights{jj}(1 : end - 1, :) = w;
                    end
                end

                % Compute cost at this iteration
                perf(ii) = (0.5 / B)*sum(sum((xNeuron{end} - OUT).^2));

                % Add in regularization if necessary
                if strcmpi(regType, 'l1')
                    for jj = 1 : L
                        perf(ii) = perf(ii) + ...
                            (lambda / B) * sum(sum(abs(this.weights{jj}(1 : end - 1, :))));
                    end
                elseif strcmpi(regType, 'l2')
                    for jj = 1 : L
                        perf(ii) = perf(ii) + ...
                            (0.5 * lambda / B) * sum(sum((this.weights{jj}(1 : end - 1, :)).^2));
                    end
                end
            end
        end

        function [OUT, OUTS] = sim(this, X)
            % sim  Perform Neural Network Testing

            % Check if the total number of features matches the
            % total number of input neurons
            assert(size(X, 2) == this.inputSize, ['Number of features '...
                   'should match the number of input neurons']);

            % Get total number of examples
            N = size(X, 1);

            %%% Begin algorithm
            % Start with input layer
            OUT = X;

            % Also initialize cell array with input layer's contents
            OUTS = cell(1, numel(this.weights) + 1);
            OUTS{1} = OUT;

            % Get activation function
            fcn = getActivationFunction(this.ActivationFunction);

            if isempty(this.OutputActivationFunction)
                fcnOut = fcn;
            else
                fcnOut = getActivationFunction(this.OutputActivationFunction);
            end

            % For each layer...
            for ii = 1 : numel(this.weights)
                % Compute inputs into each neuron and corresponding
                % outputs
                if ii == numel(this.weights)
                    OUT = fcnOut([OUT ones(N, 1)] * this.weights{ii});
                else
                    OUT = fcn([OUT ones(N, 1)] * this.weights{ii});
                end
                OUTS{ii + 1} = OUT;
            end
        end
    end
end

function fcn = getActivationFunction(activation)
    switch lower(activation)
        case 'linear'
            fcn = @f_linear;
        case 'relu'
            fcn = @f_relu;
        case 'tanh'
            fcn = @f_tanh;
        case 'sigmoid'
            fcn = @f_sigmoid;
        otherwise
            error('Unknown activation function');
    end
end

function fcn = getDerivativeActivationFunction(activation)
    switch lower(activation)
        case 'linear'
            fcn = @fd_linear;
        case 'relu'
            fcn = @fd_relu;
        case 'tanh'
            fcn = @fd_tanh;
        case 'sigmoid'
            fcn = @fd_sigmoid;
        otherwise
            error('Unknown activation function');
    end
end

% activation funtions and their derivatives
function y = f_linear(x)
    % See also: purelin
    y = x;
end

function y = fd_linear(x)
    % See also: dpurelin
    y = ones(size(x));
end

function y  = f_relu(x)
    % See also: poslin
    y = max(x, 0);
end

function y = fd_relu(x)
    % See also: dposlin
    y = double(x >= 0);
end

function y = f_tanh(x)
    % See also: tansig
    %y = 2 ./ (1 + exp(-2*x)) - 1;
    y = tanh(x);
end

function y = fd_tanh(x)
    % See also: dtansig
    y = f_tanh(x);
    y = 1 - y.^2;
end

function y = f_sigmoid(x)
    % See also: logsig
    y = 1 ./ (1 + exp(-x));
end

function y = fd_sigmoid(x)
    % See also: dlogsig
    y = f_sigmoid(x);
    y = y .* (1 - y);
end
