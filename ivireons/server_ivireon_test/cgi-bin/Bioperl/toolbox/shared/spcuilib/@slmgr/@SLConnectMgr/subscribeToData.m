function retval = subscribeToData(this, hDataSink)
%CONNECTTODATA subscribe to data event of simulink model
%   OUT = CONNECTTODATA(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/23 19:07:18 $

if nargin < 2
    hDataSink = slmgr.SLDataSink;
end

% Change this to INTERFACE when we get the chance with MCOS.
% if ~isa(hDataSink, 'slmgr.SLDataSink')
%     slmgr.errMsg = 'An instance of SLDataSink is required';
%     retval = false;
%     return;
% end

this.hDataSink = hDataSink;
this.errMsg = this.hSignalData.CacheAttribsAndRTO(this.hSignalSelectMgr);
if ~isempty(this.errMsg)
    retval = false;
    return;
end

this.hSignalData.InstallRTO(hDataSink);
retval = true;

% [EOF]
