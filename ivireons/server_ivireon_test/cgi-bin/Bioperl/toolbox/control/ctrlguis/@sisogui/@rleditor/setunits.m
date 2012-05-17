function setunits(this,Type,NewValue)
% Sets editor units.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:43:45 $
switch Type
   case 'FrequencyUnits'
      this.FrequencyUnits = NewValue;
end
