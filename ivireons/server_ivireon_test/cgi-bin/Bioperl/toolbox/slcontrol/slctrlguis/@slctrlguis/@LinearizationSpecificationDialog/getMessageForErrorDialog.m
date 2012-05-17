function [msg,status] = getMessageForErrorDialog(this,varargin)
% getMessageForErrorDialog

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2009/04/21 04:50:21 $

% If we are in both shipping and testing mode be sure to return a message
% and status.  The status is masked in case of testing.
msg = ctrlMsgUtils.message(varargin{:});
if this.isTesting
    ctrlMsgUtils.warning(varargin{:});
    status = true;
else
    status = false;
end