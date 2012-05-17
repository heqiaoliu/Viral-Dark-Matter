function newval = todb(h,val,notused)
%TODB Convert squared value to dB.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:28:43 $

newval = 10*log10(1/val);
