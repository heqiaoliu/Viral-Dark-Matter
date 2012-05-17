function this = ExtensionDb(hRegisterDb, hConfigDb, hApplication, hMessageLog)
%ExtensionDb Constructor for Extensions Instance Database.
%   InstanceDb(hRegisterDb,hConfigDb,hAppInst) constructs a new extension
%   instance database, passing the extension registry database, 
%   configuration database, and application-instance handles.
%   All arguments are required.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:34 $

% Instantiate and record handles to databases
this            = extmgr.ExtensionDb;
this.RegisterDb = hRegisterDb;
this.ConfigDb   = hConfigDb;

% Record handle to the application instance
% This is NOT an instance of the extension object.
% This is a handle to the parent application - say, a scope instance.
% It is specific to the client-app.  This instance object is used as an
% argument to the constructor for an extension instance object.
this.Application = hApplication;

if nargin > 3
    this.MessageLog = hMessageLog;
end

% Add a destructor which calls remove to disable and delete each child.
spcuddutils.addDestructor(this, @(this, ed) remove(this));

% [EOF]
