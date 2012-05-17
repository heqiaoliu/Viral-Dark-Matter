function buffer_reset(h);
%RESET  Reset buffer object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:12 $

flush(h);
h.NumNewSamples = 0;
h.NumSamplesProcessed = 0;
