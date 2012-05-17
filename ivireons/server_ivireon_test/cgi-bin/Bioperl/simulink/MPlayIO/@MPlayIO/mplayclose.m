function mplayclose(blk)
%MPLAYCLOSE Closes instance of MPlay for Signal and Scope Manager.
%
%   NOTE: This function assumes it is being called from the
%         CloseFunction of the MPlay library block.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/05/20 00:29:50 $


debug = false;

if nargin<1, blk=gcbh; end

% Get IO Manager object from block user data
ioObj = get_param(blk,'userdata');

% Is this a valid handle to an instance of MPlay?
isValid = ~isempty(ioObj) && isa(ioObj.hMPlay, 'uiscopes.Framework');
if isValid
    ioObj.hMPlay.close;
end

% [EOF]
