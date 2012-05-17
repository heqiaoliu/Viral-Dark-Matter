function [status, errmsg] = callbackPreApplyPID(source,dialog)

% CALLBACKPREAPPLYPID This is the preApply callback for dialogs of the PID
% blocks.

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/12/28 04:38:23 $

% Calling the default preapplycallback implementation
[status, errmsg] = source.preApplyCallback(dialog);

% NOTE: preApplyCallback expects two outputs, otherwise will fail on UNIX.
% See g511423