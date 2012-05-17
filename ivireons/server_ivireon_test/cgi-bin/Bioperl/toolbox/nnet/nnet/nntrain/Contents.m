% Neural Network Toolbox Training Functions.
%
% Backpropagation training functions
%
%   trainbfg  - BFGS quasi-Newton backpropagation.
%   trainbr   - Bayesian Regulation backpropagation.
%   traincgb  - Conjugate gradient backpropagation with Powell-Beale restarts.
%   traincgf  - Conjugate gradient backpropagation with Fletcher-Reeves updates.
%   traincgp  - Conjugate gradient backpropagation with Polak-Ribiere updates.
%   traingd   - Gradient descent backpropagation.
%   traingda  - Gradient descent with adaptive lr backpropagation.
%   traingdm  - Gradient descent with momentum.
%   traingdx  - Gradient descent w/momentum & adaptive lr backpropagation.
%   trainlm   - Levenberg-Marquardt backpropagation.
%   trainoss  - One step secant backpropagation.
%   trainrp   - RPROP backpropagation.
%   trainscg  - Scaled conjugate gradient backpropagation.
%
% Supervised weight/bias training functions
%
%   trainb    - Batch training with weight & bias learning rules.
%   trainc    - Cyclical order weight/bias training.
%   trainr    - Random order weight/bias training.
%   trains    - Sequential order weight/bias training.
%
% Unsupervised weight/bias training functions
%
%   trainbu   - Unsupervised batch training with weight & bias learning rules.
%   trainru   - Unsupervised random order weight/bias training.
%
% <a href="matlab:help nnet/Contents.m">Main nnet function list</a>.
 
% Copyright 1992-2010 The MathWorks, Inc.
