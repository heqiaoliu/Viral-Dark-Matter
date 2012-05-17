function this = SLModel(name)
% SLMODEL Constructor
%
% NAME is a Simulink model name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:25:55 $

% Create object
this = modelpack.SLModel;

% No argument constructor call
if nargin == 0
  return
end

% First, ask the Model Manager if the model exists.
h = addModel( modelpack.ModelManager, this, name );

if (this == h)
  % Model does not exist
  try
    % Set properties
    this.Name    = name;
    this.Version = 1.0;

    % Get model information
    update(this, 'all');
  catch E
    % Remove uninitialized model.
    removeModel( modelpack.ModelManager, this );
    rethrow(E);
  end
else
  % Model already exists
  this = h;
end
