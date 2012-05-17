function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:15 $

Str = sprintf('Gain-Phase requirement');

if (nargin == 2) && strcmp(keyword, 'detail')
   if strcmp(Constr.Type, 'upper')
      Str = sprintf('Upper limit Gain-Phase requirement');
   else
      Str = sprintf('Lower limit Gain-Phase requirement');
   end
   XUnits = Constr.getDisplayUnits('XUnits');
   Range = unitconv(Constr.OLPhase(:), ...
      Constr.PhaseUnits, ...
      XUnits);
   Str = sprintf('%s from %0.3g to %0.3g %s', ...
      Str, min(Range), max(Range), XUnits);
end

if (nargin == 2) && strcmp(keyword, 'identifier')
   Str = 'GPRequirement';
end
