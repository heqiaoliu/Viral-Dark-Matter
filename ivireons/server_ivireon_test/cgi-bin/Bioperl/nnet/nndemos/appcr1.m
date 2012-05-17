%APPCR1 Character recognition.

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.15.2.5 $  $Date: 2010/04/24 18:06:41 $

clf;
figure(gcf)

echo on


%    NEWFF   - Initializes feed-forward networks.
%    TRAINGDX - Trains a feed-forward network with faster backpropagation.
%    SIM   - Simulates feed-forward networks.

%    CHARACTER RECOGNITION:

%    Using the above functions a feed-forward network is trained
%    to recognize character bit maps, in the presence of noise.

pause % Strike any key to continue...

%    DEFINING THE MODEL PROBLEM
%    ==========================

%    The script file PRPROB defines a matrix ALPHABET
%    which contains the bit maps of the 26 letters of the
%    alphabet.

%    This file also defines target vectors TARGETS for
%    each letter.  Each target vector has 26 elements with
%    all zeros, except for a single 1.  A has a 1 in the
%    first element, B in the second, etc.

[alphabet,targets] = prprob;

pause % Strike any key to define the network...

%    DEFINING THE NETWORK
%    ====================

%    The character recognition network will have 25 TANSIG
%    neurons in its hidden layer.

net = newff(alphabet,targets,25);

pause % Strike any key to train the network...

%    TRAINING THE NETWORK WITHOUT NOISE
%    ==================================

%    The network will be trained without dividing data up into
%    training and validation sets, because this is a small problem
%    with only 26 samples.
%
%    The performance goal will be a mean square error of 0.001.
%    
%    Training begins...please wait...

net.divideFcn = '';
net.trainParam.goal = 0.001;

[net1,tr] = train(net,alphabet,targets);

%    ...and finally finishes.

pause % Strike any key to train the network with noise...

%    TRAINING THE NETWORK WITH NOISE
%    ===============================

%    The network will be trained on the original letters
%    along with 10 sets of noisy letters.

numNoisy = 10;
inputs2 = [alphabet repmat(alphabet,1,numNoisy)+randn(35,26*numNoisy)*0.2];
targets2 = [targets repmat(targets,1,numNoisy)];
[net2,tr] = train(net,inputs2,targets2);

%    ...and finally finishes.

pause % Strike any key to test the networks...

%    TRAINING THE NETWORK
%    ====================

% SET TESTING PARAMETERS
noise_range = 0:.05:.5;
max_test = 100;
network1 = [];
network2 = [];
T = targets;

% PERFORM THE TEST
for noiselevel = noise_range
  fprintf('Testing networks with noise level of %.2f.\n',noiselevel);
  errors1 = 0;
  errors2 = 0;

  for i=1:max_test
    P = alphabet + randn(35,26)*noiselevel;

    % TEST NETWORK 1
    A = net1(P);
    AA = compet(A);
    errors1 = errors1 + sum(sum(abs(AA-T)))/2;

    % TEST NETWORK 2
    An = net2(P);
    AAn = compet(An);
    errors2 = errors2 + sum(sum(abs(AAn-T)))/2;
    echo off
  end

  % AVERAGE ERRORS FOR 100 SETS OF 26 TARGET VECTORS.
  network1 = [network1 errors1/26/100];
  network2 = [network2 errors2/26/100];
end
echo on

pause % Strike any key to display the test results...

%    DISPLAY RESULTS
%    ===============

%    Here is a plot showing the percentage of errors for
%    the two networks for varying levels of noise.

clf
plot(noise_range,network1*100,'--',noise_range,network2*100);
title('Percentage of Recognition Errors');
xlabel('Noise Level');
ylabel('Errors');
legend('Network 1','Network 2','Location','NorthWest')

%    Network 1, trained without noise, has more errors due
%    to noise than does Network 2, which was trained with noise.

echo off
disp('End of APPCR1')

 
