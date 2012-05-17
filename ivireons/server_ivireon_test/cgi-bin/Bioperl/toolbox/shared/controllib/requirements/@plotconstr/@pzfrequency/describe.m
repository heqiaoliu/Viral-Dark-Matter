function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:18 $

Str = xlate('Natural frequency');

if (nargin == 2) && strcmp(keyword, 'detail')
  str1 = unitconv(Constr.Frequency, 'rad/sec', Constr.FrequencyUnits);
  
  Str = sprintf('%s (%0.3g)', Str, str1);
end

if (nargin == 2) && strcmp(keyword, 'identifier')
  Str = 'NaturalFrequency';
end
