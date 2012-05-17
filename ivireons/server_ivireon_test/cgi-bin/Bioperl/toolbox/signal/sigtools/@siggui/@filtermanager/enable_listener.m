function enable_listener(this, eventData)
%ENABLE_LISTENER   Listener to the 'enable' property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/12/26 22:21:23 $

h = get(this, 'Handles');

% only enable the cascade/parallel options if there is more than 1 filter
% selected.
if length(this.SelectedFilters) > 1
    enab = this.Enable;
else
    enab = 'Off';
end
% setenableprop([h.cascade h.parallel], enab);
setenableprop(h.cascade, enab);

% You need to have at least 1 filter selected to delete or view.
if isempty(this.SelectedFilters)
    enab = 'Off';
else
    enab = this.Enable;
end
setenableprop([h.delete h.fvtool h.rename], enab);

if isempty(this.Data)
    enab = 'Off';
else
    enab = this.Enable;
end
setenableprop([h.listbox h.overwrite], enab);

% [EOF]
