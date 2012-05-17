function ok = sim(net,x,xi,ai,seed)
%SIM Test command line, Simulink and RTW simulation code

% Copyright 2010 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t] = nntest.rand_problem(seed);
end

if nargin == 1, clc, end
disp(' ')
disp(['========== NNTEST.SIM(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,t,seed); disp(' '); end

rand('seed',seed);
ok = test_sim(net,x,xi,ai);

if ok, result = 'PASSED'; else result = 'FAILED'; end
disp(' ')
disp(['========== NNTEST.SIM(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function ok = test_sim(net,x,xi,ai)

TS = nnfast.numtimesteps(x);
Q = nnfast.numsamples(x);

absTolerance = 1e-13 * sqrt(TS);
relTolerance = 1e-12 * sqrt(TS);

% ====== VIEW TESTS ======

diagram = view(net);

% ====== COMMAND LINE TESTS ======

disp('COMMAND LINE:')
disp(' ')

[y,xf,af] = sim(net,x,xi,ai);

disp('SIM(NET,X,Xi,Ai) called.');
disp(' ')

% ====== NETWORK DATA CHECKS ======

disp('SIMULINK:')
disp(' ')

% Skip Unsupported Networks
% skip = simulink_check(net);
% if ~isempty(skip)
%   disp(['Skipping SIMULINK and RTW Tests: ' skip]);
%   disp(' ')
%   diagram.setVisible(false);
%   diagram.dispose()
%   ok = true;
%   return
% end

% ====== SIMULINK TESTS ======

% Remove zero sized and unused inputs, layers, outputs and weights
[net2,PI,PL,PO] = prune(net);
[x2,xi2,ai2] = prunedata(net2,PI,PL,PO,x,xi,ai);

% Replace non-finite data with random values
for i=1:numel(x2)
  ind = find(~isfinite(x2{i}));
  x2{i}(ind) = rands(1,length(ind));
end
for i=1:numel(xi2)
  ind = find(~isfinite(xi2{i}));
  xi2{i}(ind) = rands(1,length(ind));
end
for i=1:numel(ai2)
  ind = find(~isfinite(ai2{i}));
  ai2{i}(ind) = rands(1,length(ind));
end

y2 = nnsim.y(net2,x2,xi2,ai2,Q);

% Generate Network
[sysName,networkName] = gensim(net2,'Name','GENSIM_Test',...
  'InputMode','workspace','OutputMode','workspace',...
  'SolverMode','discrete');
pause(0.05)

disp('GENSIM(NET) called.');
disp(' ')

% Simulate Network
set_param(getActiveConfigSet(sysName),...
  'StartTime','0','StopTime',num2str(TS-1),...
  'ReturnWorkspaceOutputs','on');

outputSizes = zeros(net2.numOutputs,1);
outputInd = find(net2.outputConnect);
for i=1:net2.numOutputs
  outputSizes(i) = net2.outputs{outputInd(i)}.size;
end

inputDelays = nn.input_delays(net2);
layerDelays = nn.layer_delays(net2);
ys = nndata(outputSizes,Q,TS,0);
pi2 = nnproc.pre_inputs(nn.subfcns(net2),xi2);
if (net2.numOutputs > 0) && (Q > 0) && (TS > 0)
  for q = 1:Q

    % Setup inputs
    for i = 1:net2.numInputs
      assignin('base',['x' num2str(i)],nndata2sim(x2,i,q));
    end

    % Setup input delay states
    for i=1:net2.numInputs
      for k=1:inputDelays(i)
        ind = net2.numInputDelays - k + 1;
        stateName = ['pi_input_' num2str(i) '_delayed_' num2str(k)];
        stateValue = pi2{i,ind}(:,q);
        set_param([sysName '/' networkName],stateName,mat2str(stateValue));
      end
    end

    % Setup layer delay states
    for i=1:net2.numLayers
      for k=1:layerDelays(i)
        ind = net2.numLayerDelays - k + 1;
        stateName = ['ai_layer_' num2str(i) '_delayed_' num2str(k)];
        stateValue = ai2{i,ind}(:,q);
        set_param([sysName '/' networkName],stateName,mat2str(stateValue));
      end
    end

    % Simulate system
    simOut = sim(sysName);

    % Get outputs
    yq = cell(net2.numOutputs,TS);
    for i = 1:net2.numOutputs
      yq(i,:) = con2seq(simOut.find(['y' num2str(i)])');
    end
    ys = nnfast.setsamples(ys,q,yq);
      
  end
end

% Compare Command-Line and Simulink Outputs
mag = sum(sum(abs(cell2mat(y2))));
if mag == 0, mag = 1; end
abs_diff = max(max(abs(cell2mat(y2) - cell2mat(ys))));
if isempty(abs_diff), abs_diff = 0; end
rel_diff = abs_diff / mag;
ok = (abs_diff < absTolerance) || (rel_diff < relTolerance);

disp(['Simulink mag output  = ' num2str(mag)])
if ok
  errstr = '';
else
  errstr = '  <<< FAILURE';
end
if (abs_diff < absTolerance);
  disp(['Simulink abs error  = ' num2str(abs_diff) ' < ' num2str(absTolerance)])
else
  disp(['Simulink abs error  = ' num2str(abs_diff) ' > ' num2str(absTolerance) errstr])
end
if (rel_diff < relTolerance);
  disp(['Simulink rel error  = ' num2str(rel_diff) ' < ' num2str(relTolerance)])
else
  disp(['Simulink rel error  = ' num2str(rel_diff) ' > ' num2str(relTolerance) errstr])
end
disp(' ')

% ====== CLOSE =====

% Clear inputs from workspace
for i = 1:net2.numInputs
  evalin('base',['clear x' num2str(i)]);
end

% Close Simulink system
close_system(sysName,0);
close_system('neural',0);

% Close network view
diagram.setVisible(false);
diagram.dispose()

pause(0.05)
    
% ====== RTW TESTS ======

%disp('RTW:')

%disp('RTW untested.')

function err = simulink_check(net)
  
% Input processing functions must support Simulink
for i=1:net.numInputs
  input = net.inputs{i};
  for j=1:length(input.processFcns)
    err = feval(input.processFcns{j},...
      'simulink_params',input.processSettings{j});
    if ischar(err), return; end
  end
end

% Transfer functions must support Simulink
for i=1:net.numLayers
  layer = net.layers{i};
  err = feval(layer.transferFcn,'simulink_params',...
    layer.size,layer.transferParam);
  if ischar(err), return; end
end

% Net input functions must support Simulink
for i=1:net.numLayers
  layer = net.layers{i};
  err = feval(layer.netInputFcn,'simulink_params',layer.netInputParam);
  if ischar(err), return; end
end

% Weight functions must support Simulink
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      weight = net.inputWeights{i,j};
      err = feval(weight.weightFcn,'simulink_params',weight.weightParam);
      if ischar(err), return; end
    end
  end
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      weight = net.layerWeights{i,j};
      err = feval(weight.weightFcn,...
        'simulink_params',weight.weightParam);
      if ischar(err), return; end
    end
  end
end

% Output processing functions must support Simulink
for i = find(net.outputConnect)
  output = net.outputs{i};
  for j=1:length(output.processFcns)
    err = feval(output.processFcns{j},...
      'simulink_reverse_params',output.processSettings{j});
    if ischar(err), return; end
  end
end

err = '';
  
% ====================================================================
