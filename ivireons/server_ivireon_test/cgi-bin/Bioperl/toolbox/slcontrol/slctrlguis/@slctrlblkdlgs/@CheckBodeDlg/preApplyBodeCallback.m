function [status, errmsg] = preApplyBodeCallback(this,dlg) 
 
% Author(s): A. Stothert 12-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:42 $

% PREAPPLYBODECALLBACK manage preapply actions for the Bode dialog
%

%Quick return if called from locked library, or if no unapplied changes
hasChanges  = dlg.hasUnappliedChanges;
[~, isLocked] = this.isLibraryBlock(this.getBlock);
if isLocked || ~hasChanges
   status = true;
   errmsg = '';
   return;
end

% Call parent class preapply callbacks
[status, errmsg] = this.preApplyLinearizationCallback(dlg);

if status
   % Finally call the Simulink super class default preApplyCallback implementation
   [status, errmsg] = this.preApplyCallback(dlg);
end
end
