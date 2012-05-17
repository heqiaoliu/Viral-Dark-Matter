function schema
% MEViewDomain Schema

%   Copyright 2009 The MathWorks, Inc.

hCreateInPackage = findpackage('DAStudio');
hThisClass       = schema.class(hCreateInPackage, 'MEViewDomain');

%% Public properties

% Name of the domain.
p = schema.prop(hThisClass, 'Name', 'string');
% Active view for this domain.
p = schema.prop(hThisClass, 'ActiveView', 'handle');
% MEViewManager which manages these domains.
p = schema.prop(hThisClass, 'ViewManager', 'handle');
% Why this is an active view?
p = schema.prop(hThisClass, 'ActiveViewReason', 'string');
p.FactoryValue = '';

%% Methods
% Set active view for the domain.
m = schema.method(hThisClass, 'setActiveView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle','handle'};

% Get active view for the domain.
m = schema.method(hThisClass, 'getActiveView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle', 'string'};

% Get factory setting if there was not active view.
m = schema.method(hThisClass, 'getFactoryView');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle'};