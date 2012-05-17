function this = STModel(Model)
% STMODEL  constructor for SISOTOOL model object
%
% Inputs:
%      Model - A sisodata.loopdata object

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/04/28 03:25:57 $

% Instantiate object
this = modelpack.STModel;

% No argument constructor call
if nargin == 0, return, end

% Check number of arguments
if nargin ~= 1
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','1')
end

% Check argument types
if isa(Model,'sisodata.loopdata')
   name = Model.Identifier;
else
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','sisodata.loopdata')
end

% First, ask the model manager if the model exists
h = addModel( modelpack.ModelManager, this, name );

if (this == h)
  % Model does not exist
  try
    % Set properties
    this.Name    = name;
    this.Version = 1.0;
    this.Model   = Model;

    % Get model information
    update(this)
  catch E
    % Remove uninitialized model.
    removeModel( modelpack.ModelManager, this );
    rethrow(E);
  end
else
  % Model already exists
  this = h;
end
