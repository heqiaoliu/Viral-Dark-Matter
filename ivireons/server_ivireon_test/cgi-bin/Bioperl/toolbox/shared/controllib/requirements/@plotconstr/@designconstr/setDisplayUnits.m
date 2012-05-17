function setDisplayUnits(this,WhichCoord,Value)
% Set units for a particular coordinate axis

%   Author: A. Stothert
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:55 $

%Check which coordinates units we are setting
switch lower(WhichCoord)
   case 'xunits'
      Units = 'xDisplayUnits';
   case 'yunits'
      Units = 'yDisplayUnits';
   otherwise
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errUnknownUnit','setDisplayUnits');
end
if ~ischar(Value)
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errArgumentType',Units);
end

%Set the new units value
this.(Units) = Value;
