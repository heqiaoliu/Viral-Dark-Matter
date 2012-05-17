function flag = ishalfnyqinterval(this)
%ISHALFNYQINTERVAL
%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:20:29 $

if strcmpi(this.SpectrumRange,'whole'),
  flag = false;
else
  flag = true;
end


% [EOF]
