function h = iirpeak
%IIRPEAK Construct an IIRPEAK object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:09:27 $

h = filtdes.iirpeak;

filterType_construct(h);

% [EOF]
