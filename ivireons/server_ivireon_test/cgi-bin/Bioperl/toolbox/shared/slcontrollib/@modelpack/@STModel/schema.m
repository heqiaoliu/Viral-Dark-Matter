function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 15:01:45 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'Model');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STModel', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'IOs', 'handle vector');               %@modelpack.STPortID
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'Parameters', 'handle vector');        %@modelpack.STParameterID
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'LinearizationIOs', 'handle vector');  %@modelpack.STLinearizationID
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'States', 'handle vector');            %@modelpack.STStateID
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'Model', 'handle');     %sisodata.loop data object handle
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
