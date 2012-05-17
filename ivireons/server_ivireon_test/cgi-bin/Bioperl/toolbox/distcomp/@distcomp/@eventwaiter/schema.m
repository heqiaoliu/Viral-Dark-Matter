function schema
%SCHEMA defines the distcomp.object class
%

% Copyright 1984-2007 The MathWorks, Inc.

% $Revision $  $Date: 2007/10/10 20:40:44 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'eventwaiter', hParentClass);


% This is the property that we will wait on - it will be changed by a listener
p = schema.prop(hThisClass, 'Mutex', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = false;

p = schema.prop(hThisClass, 'Listeners', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'Timeout', 'double');
p.AccessFlags.Init = 'on';
p.FactoryValue = Inf;
p.SetFunction = @iSetTimeout;

p = schema.prop(hThisClass, 'EventReceived', 'bool');
p.AccessFlags.Init = 'on';
p.FactoryValue = true;

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function val = iSetTimeout(obj, val) %#ok<INUSL>
if val < 0
    warning('distcomp:eventwaiter:InvalidProperty', 'Attempt to set timeout negative, setting to 0');
    val = 0;
end


