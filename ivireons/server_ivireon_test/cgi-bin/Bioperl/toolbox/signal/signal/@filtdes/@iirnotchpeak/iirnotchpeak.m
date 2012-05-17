function h = iirnotchpeak
%IIRNOTCHPEAK Construct an IIRNOTCHPEAK object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:21:28 $

h = filtdes.iirnotchpeak;

set(h, 'Tag', 'IIR Notch/Peak');

designMethodwFs_construct(h);

% [EOF]
