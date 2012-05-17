function filterOrder = set_filterorder(this, filterOrder)
%SET_FILTERORDER PreSet function for the 'FilterOrder' property
%   OUT = SET_FILTERORDER(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:16 $

if mod(filterOrder, 2)
    error(generatemsgid('InvalidFilterOrder'),...
        'FilterOrder must be an even number.');
end

% [EOF]
