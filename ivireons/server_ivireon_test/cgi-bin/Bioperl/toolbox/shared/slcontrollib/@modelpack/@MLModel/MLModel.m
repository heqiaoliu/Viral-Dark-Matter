function this = MLModel(modelfcn, varargin)
% MLMODEL Constructor
%
% h = modelpack.MLModel(@mfile, Nin, Nout, Nstates, 'param1', value1, ...);
%
% MODELFCN is a Matlab function handle.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:52:47 $

% Create object
this = modelpack.MLModel;

% No argument constructor call
if nargin == 0
  return
end

% First, ask the Model Manager if the model exists.
h = addModel( modelpack.ModelManager, this, func2str(modelfcn) );

if (this == h)
  % Model does not exist

  % Set properties
  this.ModelFcn  = modelfcn;
  this.ModelData = LocalParseArguments(varargin);
  this.Version   = 1.0;

  % Get model information
  update(this, 'all');
else
  % Model already exists
  this = h;
end

% ----------------------------------------------------------------------------
function modeldata = LocalParseArguments(args)
modeldata = struct( 'Inport',  args{1}, ...
                    'Outport', args{2}, ...
                    'States',  args{3}, ...
                    'Parameters', [] );

if length(args) > 4
  modeldata.Parameters = args(4:end);
end
