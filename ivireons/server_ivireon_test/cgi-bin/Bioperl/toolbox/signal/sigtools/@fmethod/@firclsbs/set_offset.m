function offset = set_offset(this, offset)
%SET_OFFSET - Preset function for 'PassbandOffset' property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:39 $

if (numel(offset) ~= 2)
    error(generatemsgid('InvalidPassbandOffset'),...
        'Passband offset must be a vector of length 2');
end
