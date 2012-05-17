function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/04/21 21:47:41 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('slcontrol');

% Construct class
c = schema.class( hCreateInPackage, 'GradientModel' );

% Class properties
% Name of model from which the gradient model will be created.
p = schema.prop(c, 'OrigModel', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Gradient model name.
p = schema.prop(c, 'GradModel', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Gradient model API object.
p = schema.prop(c, 'hModel', 'handle');
set( p, 'AccessFlags.PublicSet', 'off' );
set( p, 'AccessFlags.PublicGet', 'on' );

% Name of workspace variable to hold masked parameter values.
p = schema.prop(c, 'WSVariable', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Content of the workspace variable whose name is in WSVariable.
p = schema.prop(c, 'Variables', 'MATLAB array');
set( p, 'SetFunction', @SetVariables, ...
  'GetFunction', @GetVariables );

% Listeners
p = schema.prop(c, 'Listeners', 'handle vector');
set( p, 'AccessFlags.PublicSet', 'off' );

% --------------------------------------------------------------------------- %
% Any time the Variables property changes, the WSVariable is updated.
function value = SetVariables(this, value)
if ~isempty( this.WSVariable )
  try %#ok<TRYNC>
    wksp = get_param(this.GradModel, 'ModelWorkspace');
    wksp.assignin(this.WSVariable, value); % Store it in model workspace.
  end
end
value = []; % Don't store it in Variables.

% --------------------------------------------------------------------------- %
% Variables are read from the workspace variable WSVariable.
function value = GetVariables(this, value)
if ~isempty( this.WSVariable )
  try %#ok<TRYNC>
    wksp = get_param(this.GradModel, 'ModelWorkspace');
    value = wksp.evalin(this.WSVariable); % Get it from model workspace.
  end
end
