function signals = y_all(net,signals,fcns)

% Copyright 2010 The MathWorks, Inc.

% TODO - OPTIMIZE MEMORY vs SPEED
% Don't use delayed processed inputs (recalculate)
% Don't keep expanded biases around (recreate)
% Don't keep all output processing steps (recover from a or y)
% Don't keep all layer outputs (recover from net input)

% Shortcuts
hint = net.hint;
IW = net.IW;
LW = net.LW;
Q = signals.Q;

% Allocate Output Signals
Zb = nntraining.bz(net,signals.Q);
TS = signals.TS;
Zi = cell(net.numLayers,net.numInputs,TS);
Zl = cell(net.numLayers,net.numLayers,TS);
N = cell(net.numLayers,TS);
Ac = [signals.Ai cell(net.numLayers,TS)];
Yp = cell(net.numOutputs,TS);
Y = cell(net.numOutputs,TS);

% Simulation
for ts=1:TS
  for i = hint.simLayerOrder
    ts2 = net.numLayerDelays + ts;
    layer = net.layers{i};
  
    % Inputs -(Input Weights)-> Weighted Inputs
	  inputInds = hint.inputConnectFrom{i};
    for j=inputInds
      pd = nntraining.pd(net,signals.Q,signals.P,signals.Pd,i,j,ts);
      weightFcn = fcns.inputWeights(i,j).weight;
      Zi{i,j,ts} = weightFcn.apply(IW{i,j},pd,weightFcn.param);
    end
    
    % Layer Outputs -(Layer Weights)-> Weighted Layer Outputs
  	layerInds = hint.layerConnectFrom{i};
    for j = layerInds
	    lw = net.layerWeights{i,j};
      if hint.layerConnectOZD(i,j);
	      Ad = Ac{j,ts2};
	    else
	      Ad = nnfast.tapdelay(Ac,j,ts2,lw.delays);
      end
      weightFcn = fcns.layerWeights(i,j).weight;
      Zl{i,j,ts} = weightFcn.apply(LW{i,j},Ad,weightFcn.param);
    end
    
    % Biases, Weighted Inputs & Layer Outputs -(Net Input Fcn)-> Net Input
    Z = [Zi(i,inputInds,ts) Zl(i,layerInds,ts) Zb(i,net.biasConnect(i))];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,signals.Q) + n; end
    N{i,ts} = n;
    
    % Net Input -(Transfer Function)-> Layer Output
    fcn = fcns.layers(i).transfer;
    Ac{i,ts2} = fcn.apply(N{i,ts},fcn.param);
    
    if net.outputConnect(i)
      
      % Layer Output -> Processed Outputs
      ii = hint.layer2output(i);
      numSteps = length(fcns.outputs(ii).process);
      y = Ac{i,ts2};
      Yp{ii,ts} = cell(1,numSteps);
      for j=numSteps:-1:1
        fcn = fcns.outputs(ii).process(j);
        if ~fcn.settings.no_change
          y = fcn.reverse(y,fcn.settings);
        end
        Yp{ii,ts}{j} = y;
      end
      
      % Processed Outputs -> Network Output
      Y{ii,ts} = y;
    end
  end
end

% Return Output Signals
signals.Zb = Zb;
signals.Zl = Zl;
signals.Zi = Zi;
signals.N = N;
signals.Ac = Ac;
signals.Y = Y;
signals.Yp = Yp;
