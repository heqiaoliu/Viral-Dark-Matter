function engageConnection(this)
%engageConnection Called when source engages a connection.
%   Overloaded by extensions requiring initialization actions.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/05/23 08:12:46 $

% Call optional (but almost always used) source-specific enable method
% overload.  All sources generally need to execute tasks upon enable, such
% as installing GUI navigation bar, etc.
engageConnection_SourceSpecific(this);

% Dump the Source enable-args so the next time the source is re-enabled,
% we don't use the same args (say, a command-line invocation).
this.ScopeCLI = [];

% [EOF]
