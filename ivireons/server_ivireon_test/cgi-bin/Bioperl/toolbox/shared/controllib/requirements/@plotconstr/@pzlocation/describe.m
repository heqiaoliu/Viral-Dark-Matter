function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:33 $


Str = sprintf('Region constraint');

if (nargin == 2) && strcmp(keyword, 'detail')
   if strcmp(Constr.Type, 'upper')
      Str = sprintf('Upper limit region requirement');
   else
      Str = sprintf('Lower limit region requirement');
   end
   XUnits = Constr.getDisplayUnits('XUnits');
   Range = unitconv(Constr.Sigma(:), ...
      Constr.SigmaUnits, ...
      XUnits);
   Str = sprintf('%s from %0.3g to %0.3g', ...
      Str, min(Range), max(Range));
end
if (nargin == 2) && strcmp(keyword, 'identifier')
   Str = 'RegionConstraint';
end
