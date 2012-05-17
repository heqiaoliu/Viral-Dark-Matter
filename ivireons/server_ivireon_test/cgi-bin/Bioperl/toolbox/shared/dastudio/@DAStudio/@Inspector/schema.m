function schema
% Sample object that implements getDialogSchema
% create its dialog by the following statement:
%

% Copyright 2004-2005 The MathWorks, Inc.

% =========================================================================
% Class Definition
% =========================================================================
hSuperPackage = findpackage('DAStudio');
hSuperClass   = findclass(hSuperPackage, 'Object');
hPackage      = findpackage('DAStudio'); 
hThisClass    = schema.class(hPackage, 'Inspector', hSuperClass);
  
% =========================================================================
% Class Methods
% =========================================================================
% getDialogSchema
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

% =========================================================================
% Class Properties
% =========================================================================
p = schema.prop(hThisClass, 'Object', 'handle');
p = schema.prop(hThisClass, 'Dialog', 'handle');