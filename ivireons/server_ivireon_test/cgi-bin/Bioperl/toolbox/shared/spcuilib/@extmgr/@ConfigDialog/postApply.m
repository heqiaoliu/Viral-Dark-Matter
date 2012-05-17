function [b, str] = postApply(this)
%POSTAPPLY Post Apply actions.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/04/09 19:04:01 $

% PreApply does the real checking.  If we've made it this far we are
% probably fine.
b   = true;
str = '';

% Enable the event so that we react to config changes.
set(this.Driver.ConfigDb, 'AllowConfigEnableChangedEvent', true);

% Process all of the configurations at once.  This reduces flicker.
processAll(this.Driver);

% [EOF]
