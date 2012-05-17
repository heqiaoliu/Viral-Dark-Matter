function h = getModelHandle(this, model)
% GETMODELHANDLE Get the handle of the MODEL
%
% MODEL is a Simulink model name or handle.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/04/21 04:28:48 $

% Get Simulink object corresponding to model
if ischar(model)
  % Make sure the model is open
  if isempty( find_system('SearchDepth', 0, 'Name', model, 'Type', 'block_diagram') )
    load_system(model);
  end

  try
    h = get_param(model, 'Object');
  catch E
    ctrlMsgUtils.error( 'SLControllib:general:InvalidModelName', model );
  end
elseif ishandle(model)
  h = handle(model);
  if ~isa(h, 'Simulink.BlockDiagram')
    ctrlMsgUtils.error( 'SLControllib:slcontrol:InvalidSimulinkModel', class(h) );
  end
else
  ctrlMsgUtils.error( 'SLControllib:general:InvalidArgument', 'MODEL', ...
    'getModelHandle', 'slcontrol.Utilities.getModelHandle');
end

% Check if the Simulink object is a block diagram
if ~strcmp(h.Type, 'block_diagram')
  ctrlMsgUtils.error( 'SLControllib:slcontrol:InvalidSimulinkModel', ...
    h.getFullName );
end
