function [labelSchema, widgetSchema] = getWidgetSchema(this, varargin)
%GETWIDGETSCHEMA   Get the widgetSchema.
%   GETWIDGETSCHEMA(H, PROP, LABEL, TYPE, ROW, COL) Returns the label and
%   widget schema information for the specified property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/03/13 19:41:20 $

[labelSchema, widgetSchema] = uiservices.getWidgetSchema(this, varargin{:});

widgetSchema.Enabled = this.Enabled;

% [EOF]
