function enable_listener(this, varargin)
%ENABLE_LISTENER   Listener to the enable property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/07/14 06:47:13 $

% Sync the "Custom" object with the reordertype.  Can't use SETUPENABLELINK
% because the reordertype is a property of another object.
if strcmpi(this.ReorderType, 'custom'),
    enab = this.Enable;
else
    enab = 'off';
end

set(getcomponent(this, 'custom'), 'Enable', enab);
set(getcomponent(this, 'overall'), 'Enable', this.Enable);

if strcmpi(this.Scale, 'Off')
    enab = 'Off';
else
    enab = this.Enable;
end

h = get(this, 'Handles');

setenableprop([h.pnorm h.maxnumerator h.numeratorconstraint ...
    h.overflowmode h.scalevalueconstraint h.scalevalueconstraint_lbl ...
    h.overflowmode_lbl h.numeratorconstraint_lbl h.pnorm_lbl' h.pnorm_tick ...
    h.pnorm_tick_lbl h.maxnumerator_lbl], enab);

if strcmpi(this.ScaleValueConstraint, 'unit')
    enab = 'Off';
end

setenableprop([h.maxscalevalue h.maxscalevalue_lbl], enab);
setenableprop(h.scale, this.Enable);

if isequal(coefficients(this.refFilter), coefficients(this.Filter))
    enab = 'off';
else
    enab = this.Enable;
end
setenableprop(h.revert, enab);

h = get(this, 'DialogHandles');

setenableprop([h.ok h.help], this.Enable);
isapplied_listener(this);

% [EOF]
