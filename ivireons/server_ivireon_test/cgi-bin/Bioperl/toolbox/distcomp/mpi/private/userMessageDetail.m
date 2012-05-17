function outputLevel = userMessageDetail(detailLevel)
; %#ok undocumented
% private function used by mpiprofile command to store -messagedetail
% settings to allow users to change the default setting on a separate
% command line.
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/18 22:14:37 $
persistent dL;
DEFAULT_MSG_DETAIL = 2;

if nargin > 0 && detailLevel >= 0
    dL = detailLevel;
elseif isempty(dL) || (nargin > 0 && detailLevel < 0)
    % the default message detail level 
    dL = DEFAULT_MSG_DETAIL;
end

if nargout > 0
    outputLevel = dL;
end
% lock the current file
mlock;