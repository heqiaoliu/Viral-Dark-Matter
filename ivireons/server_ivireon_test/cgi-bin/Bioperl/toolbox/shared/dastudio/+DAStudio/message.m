function [oMsg, oId, treatAsSimulinkError] = message(inMsgId, varargin)
% DASTUDIO.MESSAGE(id, varargin) is obsolete.  Use MessageID

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/25 08:24:05 $


mObj = MessageID(inMsgId);
oMsg = mObj.message(varargin{:});

oId  = inMsgId;
treatAsSimulinkError = false;

end % DAStudio.message
