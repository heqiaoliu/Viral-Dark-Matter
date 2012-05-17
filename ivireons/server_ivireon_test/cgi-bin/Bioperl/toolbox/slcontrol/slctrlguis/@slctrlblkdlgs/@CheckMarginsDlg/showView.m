function showView(this,dlg)
%

% Author(s): A. Stothert 11-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:12 $

% SHOWVIEW  wrapper function around callbackView to first check if the
% dialog has unapplied changes. Needed as we may need to change the
% visualization plot type. 
%

if dlg.hasUnappliedChanges
   dlg.apply
end
this.callbackView;
end
