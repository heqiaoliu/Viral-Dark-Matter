function schema
% SCHEMA - define Simulink.DialogProvider class structure

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/15 23:30:02 $

% Simulink.DialogProvider is derived from DAStudio.Object
pk = findpackage('DAStudio');
hDeriveFromClass   = findclass(pk, 'Object');
% Construct class
hThisClass = schema.class(pk, 'DialogProvider', hDeriveFromClass);

%%%%%%%%%%%%%% Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Private storage used for dialogs
hThisProp = schema.prop(hThisClass, 'pDialogData', 'MATLAB array');
hThisProp.AccessFlags.PublicSet = 'off';

%%%%%%%%%%%%%%%%%%%%%% Methods %%%%%%%%%%%%%%%%%%%%

m = schema.method(hThisClass, 'pDialogCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle','string','handle'};
s.OutputTypes = {'bool','string'};

m = schema.method(hThisClass, 'pControlCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle','string','handle'};
s.OutputTypes = {};

m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

