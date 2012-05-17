function [success, message] = rmicheck_post(system) %#ok<INUSD>

% Copyright 2009-2010 The MathWorks, Inc.

% This gets called afeter all selected checks are done. It should be safe
% to destroy 3-rd party applications opened by us.
% If the call is shared by multiple checks it may be called more than once,
% which is not a huge problem because cleanup of clean state is cheap.

%fprintf(1, 'rmicheck_post() called for ''%s''\n', get_param(system, 'Name'));

success = rmi.mdlAdvState('cleanup');

if success == 0
    message = 'mdlAdvState cleanup failed';
else
    message = '';
end

