function varargout = getWidgetSchema(hCfg, prop, varargin)
%GETWIDGETSCHEMA Get the widgetSchema.
%   uiscopes.getWidgetSchema(HCFG,PROP,TYPE,ROW,COL) Returns the widget
%   schemas for the widget specified by PROP in the config HCFG.  The label
%   will be determined via uiscopes.message([prop 'Label']).
%
%   See also uiservices.getWidgetSchema, extmgr.getWidgetSchema.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:53:44 $

% Use uiscopes.message to get the label by adding 'Label' to the prop name.
label = uiscopes.message([prop 'Label']);
[varargout{1:nargout}] = extmgr.getWidgetSchema(hCfg, prop, label, varargin{:});

% [EOF]
