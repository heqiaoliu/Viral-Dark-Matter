function schema
% SCHEMA - define emlcoder.InferenceReport class structure

%   Copyright 2003-2009 The MathWorks, Inc.

%%%% Get handles of associated packages and classes
% emlcoder.InferenceReport class derived from DAStudio.Object class.
hDeriveFromPackage = findpackage('DAStudio');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'Object');
hCreateInPackage   = findpackage('emlcoder');
%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'InferenceReport', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'Document', 'string');
hThisProp.FactoryValue = '';
hThisProp = schema.prop(hThisClass, 'DocumentTitle', 'string');
hThisProp.FactoryValue = '';
% 

m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

m = schema.method(hThisClass, 'getModelExplorer');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string'};
s.OutputTypes = {'mxArray'};
