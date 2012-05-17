function numInputs = getNumInputs(this)
%GETNUMINPUTS Get the numInputs.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:52 $

if ~isempty(this.SLConnectMgr) && ~isempty(this.SLConnectMgr.hSignalSelectMgr)
    numInputs = numel(this.SLConnectMgr.hSignalSelectMgr.Signals);
else
    numInputs = 1;    
end

% [EOF]
