function this = SignalData(varargin)
%SIGNALDATA Construct a SIGNALDATA object
%   varargin: args to establish connection,
%             generally {lineh} or {blkh} or {blkh,portIdx}
%
% Maintains a connection to run-time data of simulink signal.
%
% When model starts, or is running at time of object instantiation,
% run-time objects are setup and data transfer occurs with client
% application.  Callbacks are put in place for this event-based transfer.
%
% If model stops, or is not running at time of object instantiation, model
% simulation state is monitored so automatic reconnection can occur.
%
% callbacks can be made to client for simulation state (stop/run).

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:50 $

this = slmgr.SignalData;
if nargin>0
    this.connect(varargin{:});
end
% [EOF]
