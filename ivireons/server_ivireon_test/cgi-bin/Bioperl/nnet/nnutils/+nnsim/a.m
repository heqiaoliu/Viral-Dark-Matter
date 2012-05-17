function [Ac,N,LWZ,IWZ,BZ]=a(net,PD,Ai,Q,TS,fcns)
%CALCA Calculate network outputs and other signals.
%
%	Syntax
%
%	  [Ac,N,LWZ,IWZ,BZ] = nnsim.a(net,Pd,Ai,Q,TS)
%
%	Description
%
%	  This function calculates the outputs of each layer in
%	  response to a networks delayed inputs and initial layer
%	  delay conditions.
%
%	  [Ac,N,LWZ,IWZ,BZ] = CALCA(NET,Pd,Ai,Q,TS) takes,
%	    NET - Neural network.
%	    Pd  - Delayed inputs.
%	    Ai  - Initial layer delay conditions.
%	    Q   - Concurrent size.
%	    TS  - Time steps.
%	  and returns,
%	    Ac  - Combined layer outputs = [Ai, calculated layer outputs].
%	    N   - Net inputs.
%	    LWZ - Weighted layer outputs.
%	    IWZ - Weighted inputs.
%	    BZ  - Concurrent biases.
%
%	Examples
%
%	  Here we create a linear network with a single input element
%	  ranging from 0 to 1, three neurons, and a tap delay on the
%	  input with taps at 0, 2, and 4 timesteps.  The network is
%	  also given a recurrent connection from layer 1 to itself with
%	  tap delays of [1 2].
%
%	    net = newlin([0 1],3,[0 2 4]);
%	    net.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>(1,1) = 1;
%	    net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{1,1}.<a href="matlab:doc nnproperty.weight_delays">delays</a> = [1 2];
%
%	  Here is a single (Q = 1) input sequence P with 8 timesteps (TS = 8),
%	  and the 4 initial input delay conditions Pi, combined inputs Pc,
%	  and delayed inputs Pd.
%
%	    P = {0 0.1 0.3 0.6 0.4 0.7 0.2 0.1};
%	    Pi = {0.2 0.3 0.4 0.1};
%	    Pc = [Pi P];
%	    Pd = nnsim.pd(net,8,1,Pc)
%
%	  Here the two initial layer delay conditions for each of the
%	  three neurons are defined:
%
%	    Ai = {[0.5; 0.1; 0.2] [0.6; 0.5; 0.2]};
%
%	  Here we calculate the network's combined outputs Ac, and other
%	  signals described above..
%
%	    [Ac,N,LWZ,IWZ,BZ] = nnsim.a(net,Pd,Ai,1,8)

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.2.1 $ $Date: 2010/07/14 23:42:35 $

% Concurrent biases
BZ = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i = 1:net.numLayers
  if net.biasConnect(i)
    BZ{i} = net.b{i}(:,ones1xQ);
  end
end

% Signals
IWZ = cell(net.numLayers,net.numInputs,TS);
LWZ = cell(net.numLayers,net.numLayers,TS);
Ac = [Ai cell(net.numLayers,TS)];
N = cell(net.numLayers,TS);

% Shortcuts
numLayerDelays = net.numLayerDelays;
inputConnectFrom = net.hint.inputConnectFrom;
layerConnectFrom = net.hint.layerConnectFrom;
layerDelays = net.hint.layerDelays;
layerHasNoDelays = net.hint.layerConnectOZD;
IW = net.IW;
LW = net.LW;

% Simulation
for ts=1:TS
  for i=net.hint.simLayerOrder
    ts2 = numLayerDelays + ts;
  
    % Input Weights -> Weighed Inputs
	  inputInds = inputConnectFrom{i};
    for j=inputInds
      weightFcn = fcns.inputWeights(i,j).weight;
      IWZ{i,j,ts} = weightFcn.apply(IW{i,j},PD{i,j,ts},weightFcn.param);
    end
    
    % Layer Weights -> Weighted Layer Outputs
  	layerInds = layerConnectFrom{i};
    for j = layerInds
	    if layerHasNoDelays(i,j);
	      Ad = Ac{j,ts2};
	    else
	      Ad = nnfast.tapdelay(Ac,j,ts2,layerDelays{i,j});
      end
      weightFcn = fcns.layerWeights(i,j).weight;
      LWZ{i,j,ts} = weightFcn.apply(LW{i,j},Ad,weightFcn.param);
    end
  
    % Net Input Function -> Net Input
    Z = [IWZ(i,inputInds,ts) LWZ(i,layerInds,ts) BZ(i,net.biasConnect(i))];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,Q) + n; end
    N{i,ts} = n;
	
    % Transfer Function -> Layer Output
    transferFcn = fcns.layers(i).transfer;
    Ac{i,ts2} = transferFcn.apply(N{i,ts},transferFcn.param);
  end
end
