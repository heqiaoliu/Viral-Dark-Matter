function error( errId, varargin )
% DASTUDIO.ERROR(errId, varargin) go from errId to error message then error
%   Will translate a messageId into a string and pass both of them to
%   the MATLAB error function.  It will also update sllasterror if requested
%   by the component.
%
%   To use this function for an already created error id
%   call DAStudio.error( errId, args)
%
%   Valid syntax for errId in DAStudio.error is
%
%   product:component:messageId
%
%   The variable arguments args are used to fill in the predefined
%   holes in the message string.

% This function is used to report an error from M-code with the following
% advantages over the MATLAB error function
%
% 1) Force the use of messageID's for
%       a) better error checking
%       b) localization capability
% 2) Have the component decide whether to push the error into sllasterror
% or not
%
% This also puts all errors through a common funnel for future upgrades
%
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/12/07 20:44:34 $

% @DAStudio.error always set LASTERROR.  +DAStudio.error does not.  To maintain
% backward compatibility, +DAStudio.error now accepts "enablelasterror" and
% "disablelasterror" options to set or disable LASTERROR.
persistent EnableLASTERROR
mlock;
if ~exist('EnableLASTERROR','var')
    EnableLASTERROR = false;
end

if (nargin == 1)
    if strcmpi(errId,'enablelasterror')
        EnableLASTERROR = true;
        return
    elseif strcmpi(errId,'disablelasterror')
        EnableLASTERROR = false;
        return
    end
end

msg.message = DAStudio.message(errId, varargin{:});

exception = MException(errId, '%s', msg.message);

if (EnableLASTERROR)
    lasterrorMsg.identifier = exception.identifier;
    lasterrorMsg.message    = exception.message;
    lasterrorMsg.stack      = exception.stack;
    lasterror(lasterrorMsg); %#ok see above comments
end

throwAsCaller(exception);
