function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:02 $

if strcmp(Constr.Format,'damping')
  Str = xlate('Damping ratio');
else
  Str = xlate('Percent overshoot');
end

if (nargin == 2) && strcmp(keyword, 'detail')
  if strcmp(Constr.Format, 'damping')
    Str = sprintf('%s (%0.3g)', Str, Constr.Damping); 
  else
    Str = sprintf('%s (%0.3g)', Str, Constr.overshoot); 
  end
end

if (nargin == 2) && strcmp(keyword, 'identifier')
  if strcmp(Constr.Format, 'damping')
    Str = 'DampingRatio'; 
  else
    Str = 'PercentOvershoot'; 
  end
end