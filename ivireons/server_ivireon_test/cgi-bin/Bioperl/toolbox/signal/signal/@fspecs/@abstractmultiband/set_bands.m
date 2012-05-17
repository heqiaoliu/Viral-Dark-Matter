function bands = set_bands(this, bands)
%SET_BANDS   PreSet function for the 'bands' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/01 12:25:37 $

if ~isnumeric(bands) || round(bands)~=bands || bands<1 || bands>10,
    error(generatemsgid('InvalidNumberofBands'), ...
    'The number of bands must be between 1 and 10.');
end

% [EOF]
