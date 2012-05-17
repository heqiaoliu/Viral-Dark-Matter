function [perf,Ac,N,BZ,IWZ,LWZ]=perf(net,P,PD,Ai,T,EW,Q,TS,fcns)
%PERF Calculate network outputs, signals, and performance.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Orlando De Jesús, Martin Hagan, Updated for parameters 7-20-05
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.2.1 $ $Date: 2010/07/14 23:42:37 $

% CALCA: [Ac,N,LWZ,IWZ,BZ] = nnsim.a(net,PD,Ai,Q,TS)
%=================================================

% Concurrent biases
BZ = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i=net.hint.biasConnectTo
  BZ{i} = net.b{i}(:,ones1xQ);
end

% Signals
IWZ = cell(net.numLayers,net.numInputs,TS);
LWZ = cell(net.numLayers,net.numLayers,TS);
Ac = [Ai cell(net.numLayers,TS)];
N = cell(net.numLayers,TS);

% Shortcuts
numLayers = net.numLayers;
numInputs = net.numInputs;
OC = net.outputConnect;
numLayerDelays = net.numLayerDelays;
inputConnectFrom = net.hint.inputConnectFrom;
layerConnectFrom = net.hint.layerConnectFrom;
biasConnectFrom = net.hint.biasConnectFrom;
inputWeightFcn = net.hint.inputWeightFcn;
netInputFcn = net.hint.netInputFcn;
transferFcn = net.hint.transferFcn;
layerWeightFcn = net.hint.layerWeightFcn;
layerDelays = net.hint.layerDelays;
IW = net.IW;
LW = net.LW;

% Function parameters
netInputParam = cell(numLayers,1);  
transferParam = cell(numLayers,1);  
inputWeightParam = cell(numLayers,numInputs);  
layerWeightParam = cell(numLayers,numLayers);  
for i=1:net.numLayers
   netInputParam{i}=net.layers{i}.netInputParam;
   transferParam{i}=net.layers{i}.transferParam;
   for j=inputConnectFrom{i}
      inputWeightParam{i,j}=net.inputWeights{i,j}.weightParam;
   end
   for j=layerConnectFrom{i}
      layerWeightParam{i,j}=net.layerWeights{i,j}.weightParam;
   end
end

% Simulation
for ts=1:TS
  for i=net.hint.simLayerOrder
    ts2 = numLayerDelays + ts;
  
    % Input Weights -> Weighed Inputs
	  inputInds = inputConnectFrom{i};
    for j=inputInds
      pd = nntraining.pd(net,Q,P,PD,i,j,ts);
      switch func2str(inputWeightFcn{i,j})  
      case 'dotprod'
        IWZ{i,j,ts} = IW{i,j} * pd;  
      otherwise  
        IWZ{i,j,ts} = feval(inputWeightFcn{i,j},IW{i,j},pd,inputWeightParam{i,j});
      end  
    end
    
    % Layer Weights -> Weighted Layer Outputs
	  layerInds = layerConnectFrom{i};
    for j=layerInds
	    thisLayerDelays = layerDelays{i,j};
	    if (length(thisLayerDelays) == 1) && (thisLayerDelays == 0)
	      Ad = Ac{j,ts2};
      else
	      Ad = cell2mat(Ac(j,ts2-layerDelays{i,j})');
      end
      switch func2str(layerWeightFcn{i,j})  
      case 'dotprod'  
        LWZ{i,j,ts} = LW{i,j} * Ad; 
      otherwise  
        LWZ{i,j,ts} = feval(layerWeightFcn{i,j},LW{i,j},Ad,layerWeightParam{i,j});
      end 
    end
  
    % Net Input Function -> Net Input
    biasInds = biasConnectFrom{i};
    Z = [IWZ(i,inputInds,ts) LWZ(i,layerInds,ts) BZ(i,biasInds)];
    switch func2str(netInputFcn{i})  
    case 'netsum'  
      N{i,ts} = Z{1};  
      for k=2:length(Z)  
        N{i,ts} = N{i,ts} + Z{k}; 
      end  
    case 'netprod'  
      N{i,ts} = Z{1};  
      for k=2:length(Z)  
        N{i,ts} = N{i,ts} .* Z{k};  
      end  
    otherwise  
      N{i,ts} = feval(netInputFcn{i},Z,netInputParam{i});
    end  
	
    % Transfer Function -> Layer Output
    switch func2str(transferFcn{i})  
    case 'purelin'  
      Ac{i,ts2} = N{i,ts};  
    case 'tansig'  
      n = N{i,ts};  
      a = 2 ./ (1 + exp(-2*n)) - 1;  
      k = find(~isfinite(a));  
      a(k) = sign(n(k));  
      Ac{i,ts2} = a;  
    case 'logsig'  
      n = N{i,ts};  
      a = 1 ./ (1 + exp(-n));  
      k = find(~isfinite(a));  
      a(k) = sign(n(k));  
      Ac{i,ts2} = a;  
    otherwise  
      Ac{i,ts2} = feval(transferFcn{i},N{i,ts},transferParam{i});
    end  
  end
end

% Process Outputs
% ===============
Al = Ac(:,(numLayerDelays+1):end);
Y = nnproc.post_outputs(fcns,Al(net.outputConnect,:));

% Performance
%============
performFcn = net.performFcn;
if isempty(performFcn);  
  performFcn = 'nullpf';
end
perf = feval(performFcn,net,T,Y,EW,net.performParam);

