function schema
% SCHEMA  Class definition of the linearization specification dialog panel.

% Author(s): John Glass
% Revised:
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:28 $

% Get handles of associated packages and classes
hParentClass = findclass(findpackage('DAStudio'),'Object');  
hCreateInPackage   = findpackage('slctrlguis');
% Construct class
c = schema.class(hCreateInPackage, 'LinearizationSpecificationDialog',hParentClass);

% Class properties
p = schema.prop(c, 'Block', 'string');   %Block requirement comes from
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c, 'Data', 'MATLAB array');    % GUI Data
p.FactoryValue = [];
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c, 'isTesting', 'MATLAB array');    % GUI Data
p.FactoryValue = false;
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c, 'Listeners', 'MATLAB array');    % Listeners
p.FactoryValue = false;
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';

% Class Methods
m = schema.method(c, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

m = schema.method(c, 'addRow');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {};

m = schema.method(c, 'remRow');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {};

m = schema.method(c, 'moveRowUp');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {};

m = schema.method(c, 'moveRowDown');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle'};
s.OutputTypes = {};

m = schema.method(c, 'methodChange');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle', 'mxArray'};
s.OutputTypes = {};

m = schema.method(c, 'specificationChange');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle', 'mxArray'};
s.OutputTypes = {};

m = schema.method(c, 'enableSpecChange');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'handle', 'mxArray'};
s.OutputTypes = {};

m = schema.method(c, 'postApplyCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {'bool', 'string'};