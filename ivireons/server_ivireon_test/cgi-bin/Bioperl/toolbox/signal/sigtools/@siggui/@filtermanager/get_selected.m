function selected = get_selected(this, selected)
%GET_SELECTED   PreGet function for the 'selected' property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:51 $

selected = get(this, 'privSelectedFilters');

% [EOF]
