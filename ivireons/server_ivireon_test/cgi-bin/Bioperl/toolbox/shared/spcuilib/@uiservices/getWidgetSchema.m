function [labelSchema, widgetSchema] = getWidgetSchema(this, prop, label, type, row, col)
%GETWIDGETSCHEMA   Get the widgetSchema.
%   GETWIDGETSCHEMA(H, PROP, LABEL, TYPE, ROW, COL) Returns the label and
%   widget schema information for the specified property.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/29 16:10:03 $

error(nargchk(4, 6, nargin, 'struct'));

if nargin < 6
    col = 1;
    if nargin < 5
        row = 1;
    end
end

labelSchema.Name    = label;
labelSchema.Type    = 'text';
labelSchema.RowSpan = [row row];
labelSchema.ColSpan = [col col];
labelSchema.Tag     = sprintf('%sLabel', prop);

widgetSchema.Type    = type;
widgetSchema.RowSpan = [row row];
widgetSchema.ColSpan = [col col]+1;
if ~strcmpi(type, 'text')
    widgetSchema.ObjectProperty = prop;
    widgetSchema.Source         = this;
    widgetSchema.Mode           = true;
    widgetSchema.Tag            = widgetSchema.ObjectProperty;
    labelSchema.Buddy           = widgetSchema.Tag;

else
    
    % When rendering text objects, we assume that the value was passed
    % instead of the property name.
    widgetSchema.Name  = prop;
    widgetSchema.Tag   = sprintf('%sValue', label);
end

% [EOF]
