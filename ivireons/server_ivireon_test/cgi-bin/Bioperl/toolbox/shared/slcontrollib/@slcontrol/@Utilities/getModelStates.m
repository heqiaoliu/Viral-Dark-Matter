function x0 = getModelStates(this, model)
% GETMODELSTATES Get model states in structure format. Only supported states
% will be returned.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/31 18:38:29 $

% Get the state structure (evalutates the function with the model compiled).
x0 = this.fevalCompiled(model, @getStateStruct, model);
end

% ----------------------------------------------------------------------------
function x0 = getStateStruct(model)
% Get the state structure from a Simulink model and remove unsupported states.

% Get the state structure from the Simulink model.
x0 = Simulink.BlockDiagram.getInitialState(model);

% If there are no states, x0 is undefined.
if ~isempty(x0)
  x0 = removeUnsupportedStates(x0);
else
  x0 = struct('time', 0, 'signals', []);
end
end

% ----------------------------------------------------------------------------
function x0 = removeUnsupportedStates(x0)
% Removes any unsupported states for parameter estimation.
% This includes:
%   non-double states
%   bus expanded unit delay states

% Eliminate non-double states and bus expanded unit delays.
if ~isempty(x0)
  for k = length(x0.signals):-1:1
    state = x0.signals(k);

    isdouble = isa(state.values, 'double');
    isbusexpanded = ~state.inReferencedModel && ...
        (numel( get_param(state.blockName, 'RunTimeObject') ) > 1);

    if ~isdouble || isbusexpanded
      x0.signals(k) = [];
    end
  end
end
end
