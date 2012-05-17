function updateParameters(this)
% UPDATEPARAMETERS Update model parameter information.
%
% Updates the parameter information in the model object, while keeping the
% identifier objects that have not changed.  The resulting object array is
% not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:11 $

new_params = LocalGetAllParameters(this);
old_params = this.Parameter;

this.Parameters = LocalMergeParameters(new_params, old_params);

% ----------------------------------------------------------------------------
function new_params = LocalGetAllParameters(this)
params = this.ModelData.Parameters;

% Create storage for identifier objects.
new_params = handle( NaN(length(params)/2,1) );
for ct = 1:length(new_params)
  % Identifier properties
  name  = params{2*ct-1};
  value = params{2*ct};
  dims  = size( value );
  type  = class(value);

  % Create new identifier.
  h = modelpack.MLParameterID(this, name, dims, type);

  % Create new value.
  new_params(ct) = modelpack.ParameterValue(this, h);
  new_params(ct).Value = value;
end

% ----------------------------------------------------------------------------
function new_params = LocalMergeParameters(new_params, old_params)
% Modifies new_params by replacing already existing elements from old_params.
for i = 1:length(new_params)
  for j = 1:length(old_params)
    % Replace with existing equivalent identifier if they are equivalent.
    if isSame( new_params(i).getID, old_params(j).getID )
      new_params(i) = old_params(j);
      % ATTN: No parameter should have more than one identifier.
      break;
    end
  end
end
