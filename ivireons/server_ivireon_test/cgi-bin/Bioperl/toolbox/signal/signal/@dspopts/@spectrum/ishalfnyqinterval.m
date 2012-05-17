function flag = ishalfnyqinterval(this)
%ISHALFNYQINTERVAL 
%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:07:06 $

if strcmpi(this.SpectrumType,'Twosided'),
  flag = false;
else
  flag = true;
end


% [EOF]
