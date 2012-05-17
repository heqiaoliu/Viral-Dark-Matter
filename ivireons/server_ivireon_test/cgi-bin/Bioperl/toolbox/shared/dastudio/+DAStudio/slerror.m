function slerror( errId, handles, varargin )
% DASTUDIO.SLERROR(errId, handles, varargin) go from errId to error message then error
%   Will translate a messageId into a string and create an MSLException  from that 
%   information.
%
%   To use this function for an already created error id
%   call DAStudio.slerror( errId, handles, args)
%
%   The variable arguments args are used to fill in the predefined
%   holes in the message string.

% This function is used to report an error from M-code with the following
% advantages over the MATLAB errror function
%
% 1) Force the use of messageID's for
%       a) better error checking
%       b) localization capability
% 2) Ability to specify handles to the simulink object that was involved 
%    with the error.
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/09/09 21:26:03 $

[msg.message, msg.identifier] = DAStudio.message(errId, varargin{:});
throwAsCaller(MSLException(handles, msg.identifier, msg.message));
