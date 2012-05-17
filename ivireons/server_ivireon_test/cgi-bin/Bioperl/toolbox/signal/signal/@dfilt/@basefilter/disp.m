function disp(Hb)
%DISP Object display.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2005/06/30 17:33:17 $

if length(this) > 1
    vectordisp(this);
else
    disp(get(Hb))
end


% [EOF]
