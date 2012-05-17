function schema
%SCHEMA defines the distcomp.proxyobject class
%

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/06/24 17:01:51 $ 

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('remoteobject');
hThisClass   = schema.class(hThisPackage, 'proxyobject', hParentClass);

p = schema.prop(hThisClass, 'ProxyObject', 'MATLAB array');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';
% This is important - we may try and set the proxy object to something with
% returns true on isequal to the current value, and yet it is in fact
% different - thus do not abort the set on isequal.
p.AccessFlags.AbortSet   = 'off';
p.SetFunction = @pSetProxyObject;

p = schema.prop(hThisClass, 'HasProxyObject', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = false;

% If a proxyobject has been created in an uncached state then it is
% possible that once the true remote representation is made some subsequent
% calls may need to be made. This flag is used to indicate that some things
% may need to be done. This field is a cell array of cell array callbacks
% that will be executed after construction
p = schema.prop(hThisClass, 'PostConstructionFcns', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = cell(0, 2);

p = schema.prop(hThisClass, 'IsBeingConstructed', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = false;

p = schema.prop(hThisClass, 'ProxyObjectEventAdaptor', 'handle');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';
p.AccessFlags.Serialize = 'off';
p.SetFunction = @pSetProxyObjectEventAdaptor;

p = schema.prop(hThisClass, 'CallbackListeners', 'handle vector');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(hThisClass, 'ProxyToUddAdaptorRegistrationCount', 'double');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';
p.AccessFlags.Serialize = 'off';

