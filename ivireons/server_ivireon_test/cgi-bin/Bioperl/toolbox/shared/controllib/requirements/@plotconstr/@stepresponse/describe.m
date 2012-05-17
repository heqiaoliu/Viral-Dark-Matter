function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: A. Stothert
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:53 $

Str = sprintf('Step response bound');

if (nargin == 2) && strcmp(keyword, 'detail')
   XUnits = Constr.getDisplayUnits('XUnits');
   Range = unitconv(Constr.Time(:), ...
      Constr.TimeUnits, ...
      XUnits);
   Str = sprintf('%s from %0.3g to %0.3g %s', ...
      Str, min(Range), max(Range), XUnits);
end
if (nargin == 2) && strcmp(keyword, 'identifier')
   Str = 'StepResponse';
end