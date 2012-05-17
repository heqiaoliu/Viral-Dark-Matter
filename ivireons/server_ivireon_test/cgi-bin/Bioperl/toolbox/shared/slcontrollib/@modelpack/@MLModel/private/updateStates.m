function updateStates(this)
% UPDATESTATES Update model state information
%
% Updates the state information in the model object, while keeping the
% identifier objects that have not changed.  The resulting object array is
% not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:53:12 $

new_states = LocalGetAllStates(this);
old_states = this.States;

this.States = LocalMergeStates(new_states, old_states);

% ----------------------------------------------------------------------------
function new_states = LocalGetAllStates(this)
states = this.ModelData.States;

% Create storage for data objects.
new_states = handle( NaN(length(states),1) );

for ct = 1:length(new_states)
  % Identifier properties
  name  = sprintf('x%d', ct);
  dims  = states(ct);
  Ts    = 0.0;

  % Create new identifier.
  h = modelpack.MLStateID(this, name, dims, Ts);
  setAliases(h, '');

  % Create new value.
  new_states(ct) = modelpack.StateValue(this, h);
end

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
