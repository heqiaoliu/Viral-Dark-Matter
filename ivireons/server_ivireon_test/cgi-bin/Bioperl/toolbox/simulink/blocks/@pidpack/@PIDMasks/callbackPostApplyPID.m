function varargout = callbackPostApplyPID(source,dialog) %#ok<INUSD>

% CALLBACKPOSTAPPLYPID This is the postApply callback for dialogs of the
% PID blocks.

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/01/25 22:58:06 $

blkh = getBlock(source);

% To invoke the initialization code. This requires that 
% set_param(gcb,'MaskRunInitForIconRedraw','on')
iconStr = get_param(blkh.Handle,'MaskDisplay');
set_param(blkh.Handle,'MaskDisplay',[iconStr sprintf('\n')]);

% NOTE: set_param parameters like Controller here will make the Dialog
% dirty because the Show parameter checkbox of the Mask for the Controller
% property is checked.

varargout = {true, ''};