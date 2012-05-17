function updateParameters(this)
% UPDATEPARAMETERS Update model parameter information.
%
% Updates the parameter information in the model object, while keeping the
% identifier objects that have not changed.  The resulting object array is
% not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/22 18:57:51 $

new_params = LocalGetAllParameters(this);
old_params = this.Parameter;

this.Parameters = LocalMergeParameters(new_params, old_params);

% ----------------------------------------------------------------------------
% Get the model parameters
function new_params = LocalGetAllParameters(this)
% Get tunable variables
S1 = getTunableParameters(this);
S2 = evalParameters( this, {S1.Name} );

% Create storage for identifier objects.
new_params = handle( NaN(length(S1),1) );
for ct = 1:length(new_params)
  % Identifier properties
  name      = S1(ct).Name;
  dims      = size( S2(ct).Value );
  class     = S1(ct).Type;
  locations = modelpack.relpath( this.Name, S1(ct).ReferencedBy );

  % Create new identifier.
  new_params(ct) = modelpack.SLParameterID( name, dims, [], class, locations );
end

% ----------------------------------------------------------------------------
function new_params = LocalMergeParameters(new_params, old_params)
% Modifies new_params by replacing already existing elements from old_params.
for i = 1:length(new_params)
  for j = 1:length(old_params)
    % Replace with existing equivalent identifier if they are equivalent.
    if isSame( new_params(i), old_params(j) )
      new_params(i) = old_params(j);
      % ATTN: No parameter should have more than one identifier.
      break;
    end
  end
end
