function f = issos(Hb)
%ISSOS  True if second-order-section.
%   ISSOS(Hb) returns 1 if filter Hb is second-order or less, and 0
%   otherwise. 
%
%   See also DFILT.   
  
%   Author: J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/08/01 18:13:31 $

f = base_is(Hb, 'thisissos');

% [EOF]
