function callbackLogging(this,tag,dlg) 
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:31 $

% CALLBACKLOGGING manage widget changes on the logging tab
%

switch tag
   case 'SaveToWorkspace'
      isenabled = dlg.getWidgetValue('SaveToWorkspace');
      dlg.setEnabled('SaveName',isenabled);
   otherwise
      %Nothing to do
end
end