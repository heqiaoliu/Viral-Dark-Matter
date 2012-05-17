function h = iirnotch
%IIRNOTCH

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:09:18 $

h = filtdes.iirnotch;

filterType_construct(h);

% [EOF]
