function callbackBounds(this,tag,dlg)  %#ok<INUSL>

% Author(s): A. Stothert 09-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:34 $

% CALLBACKBOUNDS manage widget changes on the bounds tab
%

switch tag
   case 'EnableUpperBound'
      dlg.setEnabled('UpperBoundFrequencies',true);
      dlg.setEnabled('UpperBoundMagnitudes',true);
   case 'EnableLowerBound'
      dlg.setEnabled('LowerBoundFrequencies',true);
      dlg.setEnabled('LowerBoundMagnitudes',true);
   otherwise
     %Nothing to do
end
end
