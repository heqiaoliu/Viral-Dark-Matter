function fcns = subfcns(net)

% Copyright 2010 The MathWorks, Inc.


% Dimensions
fcns.numInputs = net.numInputs;
fcns.numLayers = net.numLayers;
fcns.numOutputs = net.numOutputs;

% Inputs
for i=1:net.numInputs
  input = [];
  
  % Processing
  num = length(net.inputs{i}.processFcns);
  if (num > 0)
    for j=1:num
      f = net.inputs{i}.processFcns{j};
      sf = feval(f,'subfunctions');
      sf.settings = net.inputs{i}.processSettings{j};
      input.process(j) = sf;
    end
  else
    input.process = [];
  end
  fcns.inputs(i) = input;
  
end

% Layers
for i=1:net.numLayers
  
  % Net Input
  f = net.layers{i}.netInputFcn;
  sf = feval(f,'subfunctions');
  sf.param = net.layers{i}.netInputParam;
  fcns.layers(i).netInput = sf;
  
  % Transfer
  f = net.layers{i}.transferFcn;
  sf = feval(f,'subfunctions');
  sf.param = net.layers{i}.transferParam;
  fcns.layers(i).transfer = sf;
  
end

% Outputs
output2layer = find(net.outputConnect);
for ii=1:net.numOutputs
  i = output2layer(ii);
  output = [];
  
  % Processing
  num = length(net.outputs{i}.processFcns);
  if (num > 0)
    for j=1:num
      f = net.outputs{i}.processFcns{j};
      sf = feval(f,'subfunctions');
      sf.settings = net.outputs{i}.processSettings{j};
      output.process(j) = sf;
    end
  else
    output.process = [];
  end
  fcns.outputs(ii) = output;
  
end

% Biases
for i=1:net.numLayers
  if net.biasConnect(i)
    
    % Learn
    f = net.biases{i}.learnFcn;
    if ~isempty(f)
      sf = feval(f,'subfunctions');
      sf.param = net.biases{i}.learnParam;
      sf.exist = true;
    else
      sf = struct;
      sf.exist = false;
    end
    fcns.biases(i).learn = sf;
  
  end
end

% Input Weights
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      
      % Weight
      f = net.inputWeights{i,j}.weightFcn;
      sf = feval(f,'subfunctions');
      sf.param = net.inputWeights{i,j}.weightParam;
      fcns.inputWeights(i,j).weight = sf;
      
      % Learn
      f = net.inputWeights{i,j}.learnFcn;
      if ~isempty(f)
        sf = feval(f,'subfunctions');
        sf.param = net.inputWeights{i,j}.learnParam;
        sf.exist = true;
      else
        sf = struct;
        sf.exist = false;
      end
      fcns.inputWeights(i,j).learn = sf;
      
    end
  end
end

% Layer Weights
for i=1:net.numLayers
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      
      % Weight
      f = net.layerWeights{i,j}.weightFcn;
      sf = feval(f,'subfunctions');
      sf.param = net.layerWeights{i,j}.weightParam;
      fcns.layerWeights(i,j).weight = sf;
      
      
      % Learn
      f = net.layerWeights{i,j}.learnFcn;
      if ~isempty(f)
        sf = feval(f,'subfunctions');
        sf.param = net.layerWeights{i,j}.learnParam;
        sf.exist = true;
      else
        sf = struct;
        sf.exist = false;
      end
      fcns.layerWeights(i,j).learn = sf;
      
    end
  end
end

% Derivatives
fcns.deriv = feval(net.derivFcn,'subfunctions');

% Performance
if ~isempty(net.performFcn)
  fcns.perform = feval(net.performFcn,'subfunctions');
  fcns.perform.param = net.performParam;
  fcns.perform.exist = true;
else
  % TODO - Empty learning function
end

