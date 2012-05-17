function [net,tr,out3,out4,out5,out6]=train(net,X,T,Xi,Ai,EW,arg7)
%TRAIN Train a neural network.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X) takes only input data, in cases where
%  the network's training function is unsupervised (i.e. does not require
%  target data).
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  <a href="matlab:doc train">train</a> calls the network training function NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> with the
%  parameters NET.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a> to perform training.  Training functions
%  may also be called directly.
%
%  <a href="matlab:doc train">train</a> arguments can have two formats: matrices, for static
%  problems and networks with single inputs and outputs, and cell arrays
%  for multiple timesteps and networks with multiple inputs and outputs.
%
%  The matrix format is as follows:
%    X  - RxQ matrix
%    Y  - UxQ matrix.
%  Where:
%    Q  = number of samples
%    R  = number of elements in the network's input
%    U  = number of elements in the network's output
%
%  The cell array format is most general:
%    X  - NixTS cell array, each element X{i,ts} is an RixQ matrix.
%    Xi - NixID cell array, each element Xi{i,k} is an RixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Y  - NOxTS cell array, each element Y{i,ts} is a UixQ matrix.
%    Xf - NixID cell array, each element Xf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%  Where:
%    TS = number of time steps
%    Ni = NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = NET.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>, 
%    No = NET.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>
%    ID = NET.<a href="matlab:doc nnproperty.net_numInputDelays">numInputDelays</a>
%    LD = NET.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Ui = NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%
%  The error weights EW can be 1, indicating all targets are equally
%  important.  It can also be either a 1xQ vector defining relative sample
%  importances, a 1xTS cell array of scalar values defining relative
%  timestep importances, an Nox1 cell array of scalar values defining
%  relative network output importances, or in general an NoxTS cell array
%  of NixQ matrices (the same size as T) defining every target element's
%  relative importance.
%
%  Here a static feedforward network is created, trained on some data, then
%  simulated using SIM and network notation.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y1 = <a href="matlab:doc sim">sim</a>(net,x)
%    y2 = net(x)
%
%  Here a dynamic NARX network is created, trained, and simulated on
%  time series data.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   Y = net(Xs,Xi,Ai)
%
%  See also INIT, REVERT, SIM, ADAPT, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2010 The MathWorks, Inc.
%  $Revision: 1.11.4.12.2.1 $ $Date: 2010/07/14 23:38:49 $

if nargin < 1, nnerr.throw('Not enough input arguments.'); end
[net,err] = nntype.network('format',net);
if ~isempty(err),nnerr.throw(nnerr.value(err,'NET')); end
if isempty(net.trainFcn), nnerr.throw('NET.trainFcn is undefined.'); end
if nargin < 2, X = {}; end % TODO - dimensionally expand
if nargin < 3, T = {}; end % TODO - default = NaN, dimensionally expand
if nargin < 4, Xi = {}; end % TODO - default = 0, dimensionally expand
if nargin < 5, Ai = {}; end % TODO - default = 0, dimensionally expand
if nargin < 6, EW = 1; end
% TODO - Expand Pd in CALCPD when Pi, Ai not supplied
% test with feedforwardnet example, net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{1,1}.<a href="matlab:doc nnproperty.weight_delays">delays</a> = [0 1 2]

% NNET 5.1 Compatibility
if (nargin == 6) && (isstruct(EW))
  [net,tr,out3,out4,out5,out6] = v51_train_arg6(net,X,T,Xi,Ai,EW);
  return
elseif (nargin == 7) && (isstruct(EW) || isstruct(arg7))
  [net,tr,out3,out4,out5,out6] = v51_train_arg7(net,X,T,Xi,Ai,EW,arg7);
  return
end

% Train
[net,tr] = feval(net.trainFcn,net,X,T,Xi,Ai,EW,net.trainParam);

% NNET 5.1 Compatibility
if nargout > 2
  [out3,out5,out6] = sim(net,X,Xi,Ai,T);
  out4 = gsubtract(T,out3);
end
