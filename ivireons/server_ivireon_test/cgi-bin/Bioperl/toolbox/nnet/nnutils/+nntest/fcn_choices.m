function fcns = fcn_choices

% Copyright 2010 The MathWorks, Inc.

persistent FCNS
if ~isempty(FCNS)
  fcns = FCNS;
  return,
end

% Process Functions
processFcns = nnpath.file2fcn(nnfile.mfiles(fullfile(nnpath.nnet_toolbox,'nnet','nnprocess')));
processFcns(strmatch('Contents',processFcns,'exact')) = [];
processFcns(strmatch('maplinlog',processFcns)) = []; % <<<<<< Derivative not implemented
fcns.inputProcessFcns = processFcns;
fcns.outputProcessFcns = processFcns;
for i=length(processFcns):-1:1
  if ~feval(fcns.inputProcessFcns{i},'processInputs')
    fcns.inputProcessFcns(i) = [];
  end
  if ~feval(fcns.outputProcessFcns{i},'processOutputs')
    fcns.outputProcessFcns(i) = [];
  end
end

% Continuous Net Input Functions
fcns.netInputFcns = nnfcn.siblings('netsum');

% Continuous Transfer Functions
fcns.transferFcns = nnfcn.siblings('tansig');

% Continuous Weight Functions
fcns.weightFcns = nnfcn.siblings('dotprod');
fcns.weightFcns(strmatch('scalprod',fcns.weightFcns)) = []; % Type 2
fcns.weightFcns(strmatch('convwf',fcns.weightFcns)) = []; % Type 2

% Performance Functions
fcns.performFcns = nnpath.file2fcn(nnfile.mfiles(fullfile(nnpath.nnet_toolbox,'nnet','nnperformance')));
fcns.performFcns(strmatch('Contents',fcns.performFcns,'exact')) = [];

% Layer Initialization Functions
fcns.initLayerFcns = nnpath.file2fcn(nnfile.mfiles(fullfile(nnpath.nnet_toolbox,'nnet','nninitlayer')));
fcns.initLayerFcns(strmatch('Contents',fcns.initLayerFcns,'exact')) = [];

% Weight/Bias Initialization Functions
initWeightFcns = nnfcn.siblings('rands');
fcns.initBiasFcns = initWeightFcns;
fcns.initInputWeightFcns = initWeightFcns;
fcns.initLayerWeightFcns = initWeightFcns;
for i=length(initWeightFcns):-1:1
  if ~feval(initWeightFcns{i},'initBias')
    fcns.initBiasFcns(i) = [];
  end
  if ~feval(initWeightFcns{i},'initInputWeight')
    fcns.initInputWeightFcns(i) = [];
  end
  if ~feval(initWeightFcns{i},'initLayerWeight')
    fcns.initLayerWeightFcns(i) = [];
  end
end

% Forward Tap Delay Mode
fcns.forwardDelayFcns = { ...
  inline('0:n')
  inline('1:max(1,n)')
  inline('n')
  inline('unique([1 n])')
  inline('find((rand(1,n)>0.5) | compet(rand(n,1))'')')
  };
fcns.feedbackDelayFcns = {
  inline('1:n')
  inline('n')
  inline('unique([1 n])')
  inline('find((rand(1,n)>0.5) | compet(rand(n,1))'')')
  };

FCNS = fcns;
