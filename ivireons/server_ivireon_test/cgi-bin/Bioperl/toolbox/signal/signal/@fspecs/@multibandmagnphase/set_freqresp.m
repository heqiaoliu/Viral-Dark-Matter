function freqresp = set_freqresp(this, freqresp)
%SET_FREQRESP   PreSet function for the 'freqresp' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:50 $


% Force row vector
freqresp = freqresp(:).';

% [EOF]
