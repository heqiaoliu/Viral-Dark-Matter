function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:27:56 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STConfig');

% -------------------------------------------------------------------------
p = schema.prop(c, 'ActiveInputs', 'handle vector');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(c, 'InputType', 'string');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.SetFunction         = @localSetType;

%--------------------------------------------------------------------------
function value = localSetType(this, value)

ValidTypes = {'step','impulse','specified'};
idx = strcmp(ValidTypes,value);
if ~any(idx)
   ctrlMsgUtils.error('SLControllib:modelpack:errValueEnumerated','InputType', '{''step''|''impulse''|''specified''}');
end

