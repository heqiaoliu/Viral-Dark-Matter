function schema
% Copyright 2009-2010 The MathWorks, Inc.

hCreateInPackage = findpackage('DAStudio');
hThisClass       = schema.class(hCreateInPackage, 'MEView');


%% Public properties
p = schema.prop(hThisClass, 'Name', 'string');
p = schema.prop(hThisClass, 'ViewManager', 'handle');
p = schema.prop(hThisClass, 'Properties', 'handle vector');
p = schema.prop(hThisClass, 'Description', 'string');

%% Private properties
p = schema.prop(hThisClass, 'PropertiesListener', 'handle');
p.Visible = 'off';
p = schema.prop(hThisClass, 'MEViewPropertyListeners', 'handle vector');
p.Visible = 'off';
p = schema.prop(hThisClass, 'GroupChangedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'InternalName', 'string');
p.Visible = 'off';
p = schema.prop(hThisClass, 'GroupName', 'string');
p.Visible = 'on';
p = schema.prop(hThisClass, 'SortName', 'string');
p.Visible = 'on';
p = schema.prop(hThisClass, 'SortOrder', 'string');
p.Visible = 'on';

%% Hooks for ME
% DDG UI for view
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'mxArray'};

% control of rows
m = schema.method(hThisClass, 'shouldShow');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {'bool'};

% control of columns
m = schema.method(hThisClass, 'getHeaderLabels');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'string vector', 'string vector'};

m = schema.method(hThisClass, 'getHeaderOrder');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string vector'};
s.OutputTypes = {'string vector'};

% control of header context menu
m = schema.method(hThisClass, 'getHeaderContextMenu');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'handle'};

%% MEView methods
m = schema.method(hThisClass, 'enableLiveliness');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {};

m = schema.method(hThisClass, 'disableLiveliness');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {};
