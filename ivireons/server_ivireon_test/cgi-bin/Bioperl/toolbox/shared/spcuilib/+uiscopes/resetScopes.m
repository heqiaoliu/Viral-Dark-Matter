function resetScopes
%resetScopes Resets all session-persistent scope data caches.
%  Closes all scope instances before resetting cache data.
%
%  Typical reasons to call this:
%   - refresh (re-discover) all extension plug-in's
%   - reset instance number due to improperly handled errors
%
%  Typical usage:
%    MPlay.resetScopes;

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2008/04/28 03:26:23 $

uiscopes.close('all'); % close any open scopes

% Remove "global" registration library
extmgr.RegisterLib.resetlib;

% [EOF]
