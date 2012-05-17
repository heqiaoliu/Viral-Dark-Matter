function this = RegisterLib
%RegisterLib Constructor for Extensions Registry Library.
%  RegisterLib returns a singleton instance of the extension registration
%  database library.  It holds multiple RegisterDb objects, each of which is
%  responsible for holding all registrations of a defined file name.
%
%  The library is a SINGLETON INSTANCE so that only one database for each
%  extension file name is recorded.  In essence, the extension file name
%  forms an index into the library.  When an extension file name is
%  specified, the extension registration database for that file name is
%  either returned from cache, or created and cached.
%
%  RegisterLib creates its own MessageLog.  If a client application wants to
%  consolidate these messages into its own MessageLog, then a reference
%  to this.hMessageLog should be linked to the client MessageLog.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:46:41 $

persistent instance;

if isempty(instance) || ~isa(instance, 'extmgr.RegisterLib')
    % RegisterLib doesn't exist yet - create one and cache it
    % in a session-wide area, protected from "clear all", etc
    %
    this = extmgr.RegisterLib;
    instance = this;
    
    % Setup non-managed MessageLog for (singleton) RegisterLib system
    %
    hMessageLog = uiservices.MessageLog('Extension Registration Library');
    hMessageLog.AutoOpenMode = 'manually';
    this.MessageLog = hMessageLog;
else
    this = instance;
end

% Lock the MATLAB file to protect the persistent variable from 'clear all'.
mlock;

% [EOF]
