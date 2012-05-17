function [errMsg, errId] = cleanErrorMessage(errMsgOrig, errId)
%CLEANERRORMESSAGE Cleaned-up version of error message.
%   uiservices.cleanErrorMessage returns a cleaned-up version of the error
%   message, cleaned up by removing backtrace info.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/11 16:06:23 $

% If we are passed an MException object we get the ID and message from
% that object.
if ~ischar(errMsgOrig)
    errId      = errMsgOrig.identifier;
    errMsgOrig = errMsgOrig.message;
elseif nargin < 2
    
    % If we are passed a single input, we can still operate as long as the
    % ID output is not requested.
    error(nargoutchk(1,1,nargout));
end

% Remove backtrace info, which is all
% lines containing and preceding the last "Error"
errMsg = errMsgOrig;
idx = strfind(errMsg,'Error');

% If we don't find the 'Error' string, look for '==>' to make sure we
% remove the header line.  We need to do this for japanese machines because
% xlate('Error') doesn't work. g406232
if isempty(idx)
    idx = strfind(errMsg, '==>');
end
if ~isempty(idx)
    % Only keep text after "Error" word
    errMsg = errMsg(idx(end)+1:end);
    
    % Remove remainder of current line, including carriage return,
    % presuming it is the rest of the traceback info on the last
    % "error" line
    idx = find(errMsg==sprintf('\n'));
    if isempty(idx)
        % no carriage return - whole message would be removed!
        % restore original and return it
        errMsg = errMsgOrig;
    else
        errMsg = errMsg(idx+1:end);
    end
end




% [EOF]
