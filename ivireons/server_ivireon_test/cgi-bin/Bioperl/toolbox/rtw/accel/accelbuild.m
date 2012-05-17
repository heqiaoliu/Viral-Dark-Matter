function accelbuild(varargin)
%ACCELBUILD Build the Accelerator MEX-file for a model.
%   This is done automatically as part of starting an accelerated
%   simulation, but can be done programmatically using this function.
%
%ACCELBUILD('MODELNAME',OPTIONS)
%   OPTIONS: OPT_OPTS=-g
%      Used to disable optimizations and add debugging symbols to
%      the generated mex file. For example to build the f14 demo model for
%      debugging:
%        accelbuild('f14','OPT_OPTS=-g');
%
%   Note that if the additional options passed into accelbuild are not
%   already part of the model's AccelMakeCommand then the AccelMakeCommand
%   will be modified and the model will become "dirty"
  
%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $

  % Get the model name
  if nargin > 0
    modelName = varargin{1};
  else
    modelName = bdroot;
    if isempty(modelName)
      error('Unable to obtain current model name.');
    end
  end

  openModels = find_system('type','block_diagram');
  modelOpen = 0;
  for i=1:length(openModels)
    mdl = openModels{i};
    if strcmp(mdl,modelName)
      modelOpen = 1;
      break;
    end
  end
  if ~modelOpen
    try
      load_system(modelName);
    catch
      error(lasterr);
      return;
    end
  end
  if nargin > 1
    currentAccelMakeCmd = get_param(modelName,'AccelMakeCommand');
    for idx = 2:nargin
        if isempty(strfind(currentAccelMakeCmd,varargin{idx}))
            currentAccelMakeCmd = [currentAccelMakeCmd,' ',varargin{idx}];
        end
    end
    set_param(modelName,'AccelMakeCommand',currentAccelMakeCmd );
  end
  try
    set_param(modelName,'simulationcommand','accelbuild');
  catch
    error(lasterr);
  end
  
%endfunction accelbuild
