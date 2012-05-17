function Y = y_only(net,signals,fcns)

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

% Allocate Signals
Zb = nntraining.bz(net,signals.Q);
Zi = cell(net.numLayers,net.numInputs);
Zl = cell(net.numLayers,net.numLayers);
N = cell(net.numLayers);
TS = signals.TS;
Ac = [signals.Ai cell(net.numLayers,TS)];
Y = cell(net.numOutputs,TS);
% TODO - cycle Ac for RAM efficiency

% Simulation
for ts=1:signals.TS
  for i = hint.simLayerOrder
    ts2 = net.numLayerDelays + ts;
    
    % Inputs -(Input Weights)-> Weighted Inputs
	  inputInds = hint.inputConnectFrom{i};
    for j=inputInds
      pd = nntraining.pd(net,signals.Q,signals.P,signals.Pd,i,j,ts);
      fcn = fcns.inputWeights(i,j).weight;
      Zi{i,j} = fcn.apply(IW{i,j},pd,fcn.param);
    end
    
    % Layer Outputs -(Layer Weights)-> Weighted Layer Outputs
  	layerInds = hint.layerConnectFrom{i};
    for j = layerInds
	    if hint.layerConnectOZD(i,j);
	      Ad = Ac{j,ts2};
	    else
	      Ad = nnfast.tapdelay(Ac,j,ts2,net.layerWeights{i,j}.delays);
      end
      weightFcn = fcns.layerWeights(i,j).weight;
      Zl{i,j} = weightFcn.apply(LW{i,j},Ad,weightFcn.param);
    end
    
    % Biases, Weighted Inputs & Layer Outputs -(Net Input Fcn)-> Net Input
    Z = [Zi(i,inputInds) Zl(i,layerInds) Zb(i,net.biasConnect(i))];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,signals.Q) + n; end
    
    % Net Input -(Transfer Function)-> Layer Output
    transferFcn = fcns.layers(i).transfer;
    Ac{i,ts2} = transferFcn.apply(n,transferFcn.param);
    
    if net.outputConnect(i)
      
      % Layer Output -> Processed Outputs
      ii = hint.layer2output(i);
      numSteps = length(fcns.outputs(ii).process);
      y = Ac{i,ts2};
      for j=numSteps:-1:1
        processFcn = fcns.outputs(ii).process(j);
        if ~processFcn.settings.no_change
          y = processFcn.reverse(y,processFcn.settings);
        end
      end
      
      % Processed Outputs -> Network Output
      Y{ii,ts} = y;
    end
  end
end
