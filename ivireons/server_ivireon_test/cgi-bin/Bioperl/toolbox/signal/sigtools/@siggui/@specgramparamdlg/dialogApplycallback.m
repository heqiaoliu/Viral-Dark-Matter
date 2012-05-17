function [status, errmsg] = dialogApplycallback(this)
%DIALOGAPPLYCALLBACK   Construct a PARAMDLG object.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/27 23:40:39 $

status = 1;
errmsg = '';
send(this,'DialogApply', handle.EventData(this, 'DialogApply'));

% [EOF]
