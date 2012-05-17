function [items, colindx] = addConstraint(this, rowindx, colindx, items, ...
    has, prop, label, tooltip)
%ADDCONSTRAINT   Add the constraints widget.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:04:52 $

if ~has
    return;
end

if nargin < 7
    label = interspace(prop);
    label = [label(1) lower(label(2:end))];
end

tunable = ~isminorder(this);

spec_lbl.Name    = label;
spec_lbl.Type    = 'text';
spec_lbl.RowSpan = [rowindx rowindx];
spec_lbl.ColSpan = [colindx colindx];
spec_lbl.Tag     = [prop 'Label'];
spec_lbl.Tunable = tunable;

if nargin > 7
    spec_lbl.ToolTip = tooltip;
end

items   = [items {spec_lbl}];
colindx = colindx+1;

% Add the widget control
spec.Type           = 'edit';
spec.RowSpan        = [rowindx rowindx];
spec.ColSpan        = [colindx colindx];
spec.ObjectProperty = prop;
spec.Source         = this;
spec.Mode           = true;
spec.Tag            = prop;
spec.Enabled        = this.Enabled;
spec.Tunable        = tunable;

colindx = colindx+1;

items = {items{:}, spec};

% [EOF]
