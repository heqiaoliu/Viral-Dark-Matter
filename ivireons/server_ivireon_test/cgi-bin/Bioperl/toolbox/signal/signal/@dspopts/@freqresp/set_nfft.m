function nfft = set_nfft(this, nfft)
%SET_NFFT   PreSet function for the 'nfft' property.

%   Author(s): J. Schickler
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:10:34 $

set(this, 'FrequencySpecification', 'NFFT');

if ischar(nfft) || nfft<=0,
    errid = generatemsgid('invalidDataType');
    errmsg = 'Invalid NFFT value.  NFFT must be a positive scalar.';
    error(errid,errmsg);
end
% [EOF]
