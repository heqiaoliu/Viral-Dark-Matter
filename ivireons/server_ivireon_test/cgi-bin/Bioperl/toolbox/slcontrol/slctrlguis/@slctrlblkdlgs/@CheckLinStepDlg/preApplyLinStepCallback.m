function [status, errmsg] = preApplyLinStepCallback(this,dlg) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:55 $

% PREAPPLYLINSTEPCALLBACK manage preapply actions for the linear step response 
% dialog
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
