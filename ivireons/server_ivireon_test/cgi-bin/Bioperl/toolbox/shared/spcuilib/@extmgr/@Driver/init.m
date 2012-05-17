function init(this, hApplication, extFile, varargin)
%INIT Initialize the extension driver object.
%  INIT(H,HAPP,REGFILE,CFGFILE) initializes an extension driver object,
%  passing it a handle to the application instance, and the name of the
%  extension registration files, e.g. 'scopext.m'.  An optional config file
%  can be specified in CFGFILE.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/08/03 21:37:29 $

error(nargchk(3,5,nargin,'struct'));

set(this, 'Application', hApplication);

% Create registration database.
% RegisterLib creates its own MessageLog, as it is a "singleton"
% library service and maintains its own, session-persistent state.
hRegisterLib = extmgr.RegisterLib;

% Link RegisterLib's (global/singleton) message log to Driver's message log
% so we see the RegisterLib messages, and any messages from child
% RegisterDb's.  Note that Driver's log is generally the same log for the
% application instance as well, so by indirection, all of RegisterLib's
% messages will be seen by the application message log.
%
% (Messages from this and ExtensionDb also show up there, by simple
% "direct connection" of the handle, performed below.)
hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    hMessageLog.LinkedLogs = hRegisterLib.MessageLog;
end

% Get registration database from global registration library manager
%
% This will either register extensions of this file name (i.e., a lot of
% loading work is done, with possible messages thrown), or quickly return
% the previously-cached database.
hRegisterDb = hRegisterLib.getRegisterDb(extFile);
this.RegisterDb = hRegisterDb;

% Create empty configuration database
hConfigDb = extmgr.ConfigDb('unnamed');
hConfigDb.AllowConfigEnableChangedEvent = false;
this.ConfigDb = hConfigDb;

% Setup listener on EnabledChanged event from individual Config objects,
% via ConfigEnableChanged event on ConfigDb.
%
% NOTE: ev.Data holds hConfig whose enable property was changed
this.ConfigEnableChangedListener = ...
    handle.listener(hConfigDb, 'ConfigEnableChanged', ...
    @(hConfigDb,ev) process(this,ev.Data));

% Create (empty) instance database object
% Pass reference to Driver's message log to ExtensionDb
% (Could be an empty handle - meaning no log)
%
% Note that this is coordinated in a simpler and different way from the
% RegisterLib message log.  Here, ExtensionDb simply posts all messages to
% the same log that Driver maintains.  However, RegisterLib has its own -
% because it's a global/singleton instance.  So for that situation, we
% allow the two logs to coexist and we link them together.
this.ExtensionDb = extmgr.ExtensionDb(hRegisterDb, hConfigDb, ...
    hApplication, hMessageLog);

% Connect the extension and config database to the driver for performance.
% The registerdb here because it is owned by the RegisterLib.
connect(this, this.ExtensionDb, 'down');
connect(this, this.ConfigDb, 'down');

% Set up listeners to rethrow "ObjectChildAdded" as "ExtensionAdded".
this.ExtensionDbChildListeners = [ ...
    handle.listener(this.ExtensionDb, 'ObjectChildAdded', ...
    @(hExtDb, ed) send(this, 'ExtensionAdded', ...
    uiservices.EventData(this, 'ExtensionAdded', ed.Child))); ...
    handle.listener(this.ExtensionDb, 'ObjectChildRemoved', ...
    @(hExtDb, ed) send(this, 'ExtensionRemoved', ...
    uiservices.EventData(this, 'ExtensionRemoved', ed.Child)))];

% Add one Config object for each Register.  Use createShallowConfig instead
% of createActiveConfig to save time.  We might be loading a Cfg file that
% contains property values and copying them here would be a waste of time
% because we would have to overwrite them with those in the Cfg file.
iterator.visitImmediateChildren(hRegisterDb, ...
    @(hRegister) hConfigDb.add(createShallowConfig(hRegister)));

% If a file was passed, load it.
if nargin > 3
    configSetLoaded = loadConfigSet(this, varargin{:});
else
    configSetLoaded = false;
end

if ~configSetLoaded
    % Impose register type constraints, such as EnableAll or EnableOne.
    imposeTypeConstraints(this);
end

% If the file has an extension, use that one as the default
% extension for the driver.
[path, file, ext] = fileparts(this.LastAccessedFile);
if ~isempty(ext)
    set(this, 'FileExtension', ext(2:end));
end

hConfigDb.AllowConfigEnableChangedEvent = true;

% Create all of the enabled extensions.
processAll(this);

% [EOF]
