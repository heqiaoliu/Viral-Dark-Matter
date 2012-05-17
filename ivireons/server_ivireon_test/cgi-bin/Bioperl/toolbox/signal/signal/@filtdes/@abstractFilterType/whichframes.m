function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:27:36 $

specObjs = get(h,'specobjs');

for n = 1:length(specObjs),
    fr(n) = whichframes(specObjs(n));  
end

