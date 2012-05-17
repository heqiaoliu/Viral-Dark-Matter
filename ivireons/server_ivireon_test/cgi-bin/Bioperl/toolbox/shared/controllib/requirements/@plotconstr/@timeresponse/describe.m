function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:07 $

if strcmpi(Constr.Type,'upper')
   Str = sprintf('Upper time response bound');
else
   Str = sprintf('Lower time response bound');
end

if (nargin == 2) && strcmp(keyword, 'detail')
   XUnits = Constr.getDisplayUnits('XUnits');
   Range = unitconv(Constr.Time(:), ...
      Constr.TimeUnits, ...
      XUnits);
   Str = sprintf('%s from %0.3g to %0.3g %s', ...
      Str, min(Range), max(Range), XUnits);
end

if (nargin == 2) && strcmp(keyword, 'identifier')
   if strcmpi(Constr.Type,'upper')
      Str = 'UpperTimeResponse';
   else
      Str = 'LowerTimeResponse';
   end
end
