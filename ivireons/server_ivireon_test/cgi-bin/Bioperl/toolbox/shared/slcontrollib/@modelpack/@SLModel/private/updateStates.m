function updateStates(this)
% UPDATESTATES Update model state information
%
% Updates the state information in the model object, while keeping the
% identifier objects that have not changed.  The resulting object array is
% not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/06/11 16:05:03 $

new_states = fevalCompiled(this, @LocalGetAllStates, this);
old_states = this.States;

this.States = LocalMergeStates(new_states, old_states);

% ----------------------------------------------------------------------------
function new_states = LocalGetAllStates(this)
% Return array
new_states = [];

% Get the state structure from the Simulink model.
xstruct = Simulink.BlockDiagram.getInitialState(this.Name);

% Return if there are no states.
if isempty(xstruct)
  return
end

% Remove unsupported states.
xstruct = LocalRemoveUnsupportedStates(xstruct);

% Sort the state names.
[~, indices] = sort( {xstruct.signals.blockName} );
xstruct.signals = xstruct.signals(indices);

% Create state id objects
states = xstruct.signals;
for ct = 1:length(states)
  S = LocalCreateStateID(this, states(ct));
  new_states = [new_states; S];
end

% ----------------------------------------------------------------------------
function S = LocalCreateStateID(this, state)
block = state.blockName;
alias = state.stateName;
value = state.values;
Ts    = state.sampleTime(1);

% ATTN: Need to handle model reference blocks.
hBlock = get_param(block, 'Object');

% Identifier properties
name = regexprep(hBlock.Name, '/', '//');
path = modelpack.relpath( this.Name, hBlock.Path );

% Create state value object.
h = modelpack.SLStateID( name, size(value), path, Ts );
h.setAliases(alias);

S = modelpack.StateValue(h);
S.Value = value;

% ----------------------------------------------------------------------------
function new_states = LocalMergeStates(new_states, old_states)
% Modifies new_states by replacing already existing elements from old_states.
for i = 1:length(new_states)
  for j = 1:length(old_states)
    % Replace with existing equivalent identifier if they are equivalent.
    if isSame( new_states(i).getID, old_states(j).getID )
      new_states(i) = old_states(j);
      % ATTN: No state should have more than one identifier.
      break;
    end
  end
end

% ----------------------------------------------------------------------------
function xstruct = LocalRemoveUnsupportedStates(xstruct)
% Remove any unsupported states for linearization and trim.
% This includes non-double, bus expanded, and model reference states.

% Eliminate non-double states and bus expanded unit delays
for ct = length(xstruct.signals):-1:1
  signal = xstruct.signals(ct);

  nondouble = ~strcmp( class(signal.values), 'double' );
  busexpand = ~signal.inReferencedModel && ...
      (numel(get_param(signal.blockName, 'RunTimeObject')) > 1);
  modelref = signal.inReferencedModel; % Remove model reference states.

  if nondouble || busexpand || modelref
    xstruct.signals(ct) = [];
  end
end
