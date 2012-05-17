function warning( warnId, varargin )
% ctrlMsgUtils.warning(warnId, varargin ) go from warnId to warn message then call warning
%   Will translate a messageId into a string and pass both of them to
%   the MATLAB warning function.  It will also update sllastwarning if requested
%   by the component.
%
%   To use this function for an already created message id
%   call ctrlMsgUtils.warning( warnId, args)
%
%   Valid syntax for warnId in ctrlMsgUtils.warning is
%
%   product:component:messageId
%
%   The variable arguments args are used to fill in the predefined 
%   holes in the message string.

% This also puts all warnings through a common funnel for future upgrades
% 
%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:11:36 $

% Create warning strings
msgString = ctrlMsgUtils.message(warnId, varargin{:});

% Throw warning
warning(warnId, '%s', msgString);