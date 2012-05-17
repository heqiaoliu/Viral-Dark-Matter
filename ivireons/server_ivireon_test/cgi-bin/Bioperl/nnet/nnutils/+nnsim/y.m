function [Y,Xf,Af] = y(net,X,Xi,Ai,Q)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, nnerr.throw('Not enough input arguments.'); end
wasMatrix = ~iscell(X);
if wasMatrix, X = {X}; end

if nargin < 3, Xi = cell(net.numInputs,0); end
if nargin < 4, Ai = cell(net.numLayers,0); end
if nargin < 5
  if ~isempty(X)
    Q = nnfast.numsamples(X);
  elseif ~isempty(Xi)
    Q = nnfast.numsamples(Xi);
  elseif ~isempty(Ai)
    Q = numsamples(Ai)
  else
    Q = 0;
  end
end

net = nn.hints(net);
fcns = nn.subfcns(net);
TS = nnfast.numtimesteps(X);

% Combine, Process, and Delay inputs
Xc = [Xi X];
Pc = nnproc.pre_inputs(fcns,Xc);
Pd = nnsim.pd(net,Pc);

% Simulate network
if (Q == 0) || (TS == 0) || (net.numOutputs == 0)
  Ac = cell(net.numLayers,net.numLayerDelays+TS);
  for i=1:net.numLayers
    Ac(i,:) = {zeros(net.layers{i}.size,0)};
  end
elseif (net.numLayerDelays == 0) && (TS > 1)
  Pd = nnsim.seq2con3(Pd);
  Ac = nnsim.a(net,Pd,Ai,Q*TS,1,fcns);
  Ac = con2seq(Ac,TS);
else
  Ac = nnsim.a(net,Pd,Ai,Q,TS,fcns);
end

% Network outputs
A = Ac(:,net.numLayerDelays+(1:TS));
Y = A(net.hint.outputInd,:);
Y = nnproc.post_outputs(fcns,Y);

% Final input and layer delay states
Xf = Pc(:,TS+(1:net.numInputDelays));
Af = Ac(:,TS+(1:net.numLayerDelays));

if wasMatrix, Y = Y{1}; end
