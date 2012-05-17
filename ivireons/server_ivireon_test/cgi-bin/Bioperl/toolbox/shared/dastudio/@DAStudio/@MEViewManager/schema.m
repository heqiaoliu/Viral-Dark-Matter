function schema
% Copyright 2009-2010 The MathWorks, Inc.

hDeriveFromPackage = findpackage('DAStudio');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'Object');
hCreateInPackage   = findpackage('DAStudio');

hThisClass = schema.class(hCreateInPackage, 'MEViewManager', hDeriveFromClass);


%% Public properties
p = schema.prop(hThisClass, 'Explorer', 'handle');
p = schema.prop(hThisClass, 'ActiveView', 'handle');
p = schema.prop(hThisClass, 'IsCollapsed', 'bool');
p.FactoryValue = true;

% Current active domain name.
p = schema.prop(hThisClass, 'ActiveDomainName', 'string');
% Current domains available.
p = schema.prop(hThisClass, 'Domains', 'handle vector');
% Do we need to suggest a view or not?
p = schema.prop(hThisClass, 'SuggestionMode', 'string');
p.FactoryValue = 'auto';
p = schema.prop(hThisClass, 'VMProxy', 'handle');


%% Private properties
p = schema.prop(hThisClass, 'METreeSelectionChangedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEListSelectionChangedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEViewModeChangedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MESearchPropertiesAddedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEClosedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEDeleteListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'ActiveViewListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'IsCollapsedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEViewAddedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MEViewRemovedListener', 'handle');
p.Visible = 'off';

p = schema.prop(hThisClass, 'MESortChangedListener', 'handle');
p.Visible = 'off';

%% Hooks for ME
% DDG UI for view manager
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

% Standalone dialog for view management
m = schema.method(hThisClass, 'getStandaloneDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'mxArray'};

% Embedded dialog for view management.
m = schema.method(hThisClass, 'getEmbeddedDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'mxArray'};

% Export Import management dialogs
m = schema.method(hThisClass, 'getExportImportDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

%
m = schema.method(hThisClass, 'addView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {};

%
m = schema.method(hThisClass, 'install');
s = m.Signature;
s.varargin    = 'on';
s.InputTypes  = {'handle', 'handle', 'bool'};
s.OutputTypes = {};

%
m = schema.method(hThisClass, 'createProxy');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle'};

% control of rows
m = schema.method(hThisClass, 'shouldShow');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {'bool'};

%
m = schema.method(hThisClass, 'eventHandler');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string', 'mxArray'};
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

% menu actions
m = schema.method(hThisClass, 'customizeView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'bool'};
s.OutputTypes = {};

m = schema.method(hThisClass, 'resetView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {};

%
m = schema.method(hThisClass, 'getView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'handle'};

%
m = schema.method(hThisClass, 'getAllViews');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle vector'};

%
m = schema.method(hThisClass, 'getActiveView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle'};

%
m = schema.method(hThisClass, 'moveBefore');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string', 'string'};
s.OutputTypes = {};

%
m = schema.method(hThisClass, 'moveAfter');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string', 'string'};
s.OutputTypes = {};

%% Persistence
% load views from preferences
m = schema.method(hThisClass, 'load');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {};

% save views to preferences
m = schema.method(hThisClass, 'save');
s = m.Signature;
s.varargin    = 'on';
s.InputTypes  = {'handle', 'handle vector', 'string'};
s.OutputTypes = {};

% reset to factory state
m = schema.method(hThisClass, 'reset');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {};

m = schema.method(hThisClass, 'getFileName');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'string'};

% create & install factory views
m = schema.method(hThisClass, 'getFactoryViews');
s = m.Signature;
s.varargin    = 'on';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'handle vector'};

m = schema.method(hThisClass, 'export');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle vector', 'string'};
s.OutputTypes = {};

m = schema.method(hThisClass, 'import');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string', 'string'};
s.OutputTypes = {'handle vector'};

%% MEView management
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

%% Domain Views
m = schema.method(hThisClass, 'getDomainString');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {'string'};

m = schema.method(hThisClass, 'createDomain');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'handle'};

m = schema.method(hThisClass, 'getSuggestedView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle', 'string'};

%% View actions.
m = schema.method(hThisClass, 'copyView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string', 'string'};
s.OutputTypes = {'handle', 'string'};

m = schema.method(hThisClass, 'removeView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'bool'};
