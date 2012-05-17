function Value = getDisplayUnits(this,WhichCoord)
% Return units for a particular coordinate axis

%   Author: A. Stothert
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:45 $

%Check which coordinate's units we are getting
switch lower(WhichCoord)
   case 'xunits'
      Units = 'xDisplayUnits';
   case 'yunits'
      Units = 'yDisplayUnits';
   otherwise
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errUnknownUnit','getDisplayUnits')
end

%Get the units value
Value = this.(Units);
