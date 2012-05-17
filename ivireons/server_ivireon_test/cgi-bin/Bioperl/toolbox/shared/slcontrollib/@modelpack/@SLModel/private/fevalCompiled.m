function varargout = fevalCompiled(this, EvalFcn, varargin)
% FEVALCOMPILED Evalutes the function EVALFCN with the model compiled.
%
% EVALFCN  is a function handle of the form @EvalFcn.
% VARARGIN is a cell array of function arguments passed to EVALFCN.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:11 $

model  = this.Name;

% Error flag
flag = false;

% Save current settings.
dirty  = get_param(model, 'Dirty');
mode   = get_param(model, 'SimulationMode');

% The model associated with this object should be compiled.
compiled = strcmp( get_param(model, 'SimulationStatus'), 'paused' );
if ~compiled
  % Set to normal mode before compiling.
  set_param(model, 'SimulationMode', 'normal');

  % Compile the model.
  try
    feval( model, [], [], [], 'compile' );
  catch Exception
    % Compile error.
    flag = true;
  end
end

try
  % Evaluate function with the model compiled.
  if ~flag
    [ varargout{1:nargout} ] = EvalFcn(varargin{:});
    feval( model, [], [], [], 'term' );
  end
catch Exception
  % Function evaluation error.
  feval( model, [], [], [], 'term' );
  flag = true;
end

% Terminate if the model has been compiled by this method.
if ~compiled
  % Restore mode after terminating.
  set_param(model, 'SimulationMode', mode);
  set_param(model, 'Dirty', dirty);
end

% Error occurred during method call.
if flag
  throw(Exception)
end
