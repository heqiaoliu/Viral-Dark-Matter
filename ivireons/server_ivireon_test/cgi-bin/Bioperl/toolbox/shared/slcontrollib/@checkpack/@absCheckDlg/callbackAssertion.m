function callbackAssertion(this,tag,dlg)
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:17 $

% CALLBACKASSERTION manage widget changes on the assertion tab
%

switch tag
   case 'enabled'
      isenabled = dlg.getWidgetValue('enabled');
      dlg.setEnabled('callback',isenabled);
      dlg.setEnabled('stopWhenAssertionFail',isenabled);
   otherwise
      %Nothing to do
end
end