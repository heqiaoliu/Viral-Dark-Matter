function f = isscalarstructure(Hb)
%ISSCALARSTRUCTURE  True if scalar filter.
%   ISSCALARSTRUCTURE(Hb) returns 1 if Hb is a scalar filter structure, and 0
%   otherwise. 
%
%   See also DFILT.   
  
%   Author: J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:40:30 $

f = base_is(Hb, 'thisisscalarstructure');

% [EOF]
