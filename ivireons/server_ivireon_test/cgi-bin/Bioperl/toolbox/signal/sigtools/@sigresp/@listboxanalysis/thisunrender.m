function thisunrender(hObj)
%THISUNRENDER Unrender this object

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 18:01:55 $

h = get(hObj, 'Handles');

% Clear out the listbox.
if ishghandle(h.listbox), set(h.listbox, 'String', {}); end

% Remove the listbox, since we do not want to unrender this.
h = rmfield(h, 'listbox');

% Convert to a vector for easy deleting.
h = convert2vector(h);

% Remove any handles that are no longer valid.
h(~ishghandle(h)) = [];

delete(h);

% [EOF]
