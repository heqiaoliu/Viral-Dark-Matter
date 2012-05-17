function x = str2num(s)
%STR2NUM Convert Java string object to numeric array.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $ $Date: 2007/02/15 21:47:50 $

x = str2num(fromOpaque(s)); %#ok

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error('MATLAB:str2num:CannotConvertClass', ...
       'Conversion to char from %s is not possible.', class(x));
end
