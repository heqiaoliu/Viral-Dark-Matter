function unsubscribeToData(this)
%UNSBSCRIBTODATA unsubscribe from simulink model for data event
%   OUT = UNSBSCRIBTODATA(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/03/17 22:42:27 $

if ~isempty(this.hDataSink)
    this.hSignalData.UninstallRTO;
    this.hDataSink = [];
end

% [EOF]
