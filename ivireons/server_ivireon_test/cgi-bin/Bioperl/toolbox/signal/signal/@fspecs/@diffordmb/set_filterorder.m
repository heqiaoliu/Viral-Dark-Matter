function filterorder = set_filterorder(this, filterorder)
%SET_FILTERORDER   PreSet function for the 'filterorder' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:35:50 $

if rem(filterorder,2),
    error(generatemsgid('InvalidOrder'), ...
        'The filter order must be even. Use the ''N'' specification for odd orders.');
end


% [EOF]
