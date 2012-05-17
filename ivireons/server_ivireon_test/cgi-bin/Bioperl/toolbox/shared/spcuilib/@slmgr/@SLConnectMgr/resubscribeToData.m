function retval = resubscribeToData(this, hDataSink, varargin)
%RESUBSCRIBETODATA connect to the newly selected data signal 
%   OUT = RESUBSCRIBETODATA(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:09:24 $

hSignalSelectMgr = slmgr.SignalSelectMgr(varargin{:}, true);
[retval, errMsg]= hSignalSelectMgr.checkConnection;

if ~retval
    this.errMsg = errMsg;
    return
end

this.hSignalSelectMgr = hSignalSelectMgr;
retval = this.subscribeToData(hDataSink);

% [EOF]
