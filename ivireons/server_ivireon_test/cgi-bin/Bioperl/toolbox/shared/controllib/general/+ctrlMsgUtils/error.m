function error( errId, varargin )
% ctrlMsgUtils.error(errId, varargin) go from errId to error message then error
%   Will translate a messageId into a string and pass both of them to
%   the MATLAB error function.  

%   To use this function for an already created error id
%   call ctrlMsgUtils.error( errId, args)
%
%   Valid syntax for errId in DAStudio.error is
%
%   product:component:messageId
%
%   The variable arguments args are used to fill in the predefined 
%   holes in the message string.

% This also puts all errors through a common funnel for future upgrades
% 
%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:11:32 $

% Create Error structure
msg.identifier = errId;
msg.message = ctrlMsgUtils.message(errId, varargin{:});

% Throw error as caller
throwAsCaller(MException(errId, '%s', msg.message))

