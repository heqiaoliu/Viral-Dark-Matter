function initialize(this, hVars)
% INITIALIZE Creates and initializes the gradient model

% Author(s): Bora Eryilmaz
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2010/04/21 21:47:40 $

% Create model for simulating the actual and the perturbed models together.
gradsys = this.GradModel;
try
  new_system( gradsys );
  set_param( gradsys, 'Location', [100 100 500 400] );
  % Create workspace variable for parameter storage through Variables prop.
  wksp = get_param(gradsys, 'ModelWorkspace');
  wksp.assignin(this.WSVariable, []);
catch E
  close_system(gradsys, 0);
  ctrlMsgUtils.error('SLControllib:slcontrol:CannotOpenGradientModel', gradsys);
end

% Get set of MATLAB variables involved in optimization.
% RE: The variable for "controller.P(1)" is "controller"
if isstruct(hVars)
  [VarNames, idx] = unique( strtok({hVars.Name}, '.({') );
  VarValues = {hVars(idx).Value};
else
  [VarNames, idx] = unique( strtok(get(hVars,{'Name'}), '.({') );
  VarValues = get(hVars(idx),{'Value'});
end

% Create variables which will be used in gradient model simulations.
% if VarNames is empty, need proper argument sizes for struct
if isempty(VarNames)
  this.Variables = struct( 'Name', VarNames, 'LValue', [], 'RValue', [] );
else
  this.Variables = struct( 'Name', VarNames, 'LValue', VarValues, 'RValue',VarValues );
end

% Copy model workspace from original model
wsOrig = get_param(this.OrigModel, 'ModelWorkspace');
wsGrad = get_param(gradsys, 'ModelWorkspace');
wsOrigData = wsOrig.data;
for ct = 1:numel(wsOrigData)
  wsGrad.assignin( wsOrigData(ct).Name, wsOrigData(ct).Value )
end

% Create the gradient model content
try
  copymdl(this);
catch E
  close_system(gradsys, 0);
  if strcmp(E.identifier, 'SLControllib:slcontrol:RefinedGradientNotAvailable')
    throw(E)
  end
  ctrlMsgUtils.error('SLControllib:slcontrol:CannotOpenGradientModel', gradsys);
end

% Make sure gradsys is properly loaded in memory.
try
  load_system(gradsys);
catch E
  close_system(gradsys, 0);
  ctrlMsgUtils.error('SLControllib:slcontrol:CannotOpenGradientModel', gradsys);
end
