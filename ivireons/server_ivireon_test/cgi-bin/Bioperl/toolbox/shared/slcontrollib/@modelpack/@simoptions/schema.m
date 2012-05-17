function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/01/15 18:57:02 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'simoptions');

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Configuration', 'handle');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'InitialState', 'handle vector');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = @LocalSetInitialState;

p = schema.prop(c, 'Outputs', 'handle vector');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = @LocalSetOutputs;

p = schema.prop(c, 'Description', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

%Events
schema.event(c,'StopSim');

% ----------------------------------------------------------------------------
function value = LocalSetOutputs(this, value) %#ok<INUSL>
cls = 'modelpack.PortID';
isValid = isa(value, cls);

if ~isempty(value) && ~isValid
  ctrlMsgUtils.error( 'SLControllib:general:VectorClassMismatch', 'Outputs', cls );
end

% ----------------------------------------------------------------------------
function value = LocalSetInitialState(this, value) %#ok<INUSL>
cls = 'modelpack.StateValue';
isValid = isa(value, cls);

if ~isempty(value) && ~isValid
  ctrlMsgUtils.error( 'SLControllib:general:VectorClassMismatch', 'InitialStates', cls );
end
