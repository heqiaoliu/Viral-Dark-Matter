function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:20 $

if strcmpi(Constr.Type,'upper')
   Str = sprintf('Upper gain limit');
else
   Str = sprintf('Lower gain limit');
end

if (nargin == 2) && strcmp(keyword, 'detail')
   XUnits = Constr.getDisplayUnits('XUnits');
   Range = unitconv(Constr.Frequency(:), ...
      Constr.FrequencyUnits, ...
      XUnits);
   Str = sprintf('%s from %0.3g to %0.3g %s', ...
      Str, min(Range), max(Range), XUnits);
end
if (nargin == 2) && strcmp(keyword, 'identifier')
   if strcmpi(Constr.Type,'upper')
      Str = 'UpperGainLimit';
   else
      Str = 'LowerGainLimit';
   end
end
