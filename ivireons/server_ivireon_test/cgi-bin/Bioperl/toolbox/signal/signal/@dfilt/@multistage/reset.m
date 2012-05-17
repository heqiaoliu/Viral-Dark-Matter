function reset(Hd)
%RESET Reset the filter.


%   Author: P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:37 $

Hd.NumSamplesProcessed = 0;

for k=1:length(Hd.Stage)
    reset(Hd.Stage(k));
end
