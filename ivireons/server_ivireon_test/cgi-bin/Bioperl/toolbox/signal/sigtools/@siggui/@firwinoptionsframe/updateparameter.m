function updateparameter(this)
%UPDATEPARAMETER   Update the Parameter controls.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/04/21 04:36:52 $

h = get(this, 'Handles');

p = getParamNames(this);

visState = 'off';

if ~isempty(p{1}) && ~(isminordersupported(this) && this.isMinOrder)
    % Can't just look at MinOrder because of the other factors.
    visState = this.Visible;
end

set([h.parameter h.parameter_lbl], 'Visible', visState);
set(h.parameter_lbl, ...
    'Tag', [p{1} '_lbl'], ...
    'String', sprintf('%s: ', xlate(interspace(p{1}))));
set(h.parameter, ...
    'Tag', p{1}, ...
    'String', get(this, 'Parameter'));

if isempty(p{2})
    visState = 'Off';
else
    visState = this.Visible;
end
set([h.parameter2 h.parameter2_lbl], 'Visible', visState);
set(h.parameter2_lbl, ...
    'Tag',    [p{2} '_lbl'], ...
    'String', sprintf('%s: ', xlate(interspace(p{2}))));
set(h.parameter2, ...
    'Tag',    p{2}, ...
    'String', get(this, 'Parameter2'));

% [EOF]
