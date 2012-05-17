function [widget_lbl, widget] = getWidgetSchema(hCfg, prop, label, type, varargin)
%GETWIDGETSCHEMA Get the widgetSchema.
%   extmgr.getWidgetSchema(HCFG,PROP,LABEL,TYPE,ROW,COL) Creates the widget
%   schemas for the extmgr.Property specified by PROP in the
%   extmgr.Config object specified by HCFG.  LABEL specifies the string to
%   use before and editbox or after a checkbox.  TYPE specifies the widget
%   type.  ROW and COL specify where to place the widget.
%
%   See also uiservices.getWidgetSchema, uiscopes.getWidgetSchema.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:07:42 $

% Get the base property setup.
hSrc = findProp(hCfg.PropertyDb, prop);

[widget_lbl, widget] = uiservices.getWidgetSchema(hSrc, 'Value', label, type, varargin{:});

% Add extension specific properties.
widget.Tag     = [hCfg.Name prop];
widget_lbl.Tag = [widget.Tag 'Label'];

widget_lbl.Buddy = widget.Tag;


% Remove mode because extensions cannot use mode true.  When Mode=true any
% changes are applied automatically and extensions would then attempt to
% update themselves with the new property values even though we have not
% applied them.
widget         = rmfield(widget, 'Mode');

% Special case checkbox.  Move the label's name to the widget and have it
% span both columns.
if strcmp(type, 'checkbox')
    error(nargoutchk(1,1,nargout))
    widget.Name = widget_lbl.Name;
    widget.ColSpan = [widget.ColSpan(1)-1 widget.ColSpan(1)];
    widget_lbl = widget;
end

% [EOF]
