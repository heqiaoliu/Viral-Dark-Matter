function varargout = fevalCompiled(~, model, EvalFcn, varargin)
% FEVALCOMPILED Evalutes the function EVALFCN with the model MODEL is compiled.
%
% Requires a valid MODEL name and a function handle EVALFCN of the form
% EvalFcn = @LocalEvalCompiled and VARARGIN is the list of arguments.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/03/31 18:38:28 $

% Error flag
flag = false;

% Save current settings.
oldDirty   = get_param(model, 'Dirty');
oldSimMode = get_param(model, 'SimulationMode');

% Set to normal mode before compiling.
set_param(model, 'SimulationMode', 'normal');

% Compile the model if needed.
compiled = strcmp( get_param(model, 'SimulationStatus'), 'paused' );
if ~compiled
  try
    feval( model, [], [], [], 'compile' );
  catch E
    flag = true;
  end
end

% Evaluate function with the model compiled.
if ~flag
  try
    [ varargout{1:nargout} ] = EvalFcn(varargin{:});
  catch E
    flag = true;
  end
  % Terminate if successfully compiled in this file.
  if ~compiled
    feval( model, [], [], [], 'term' );
  end
end

% Restore old settings.
set_param(model, 'SimulationMode', oldSimMode);
set_param(model, 'Dirty', oldDirty);

% Error occurred either during compilation or function evaluation.
if flag
  throw(E)
end
