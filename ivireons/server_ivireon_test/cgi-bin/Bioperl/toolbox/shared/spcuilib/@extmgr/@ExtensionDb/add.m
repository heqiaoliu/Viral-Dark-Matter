function add(this, hRegister, hConfig, varargin)
%ADD Add an instance-specific copy of an extension that is
%    to remain persistent for the lifecycle of a scope instance,
%    until explicitly removed (disabled).
%
%    add(this,hRegister,hConfig) creates and adds an extension instance
%    corresponding to registration hRegister, using property values as
%    specified by configuration hConfig.
%
%    If omitted, the existing configuration object (hConfig) is
%    taken from the configuration database (ConfigDb).
%
%    hRegister may be obtained from RegisterDb using:
%       hRegister = findRegister(hRegisterDb,extType,extName)
%
%    ADD calls enableExtension(hExtension) method after connecting,
%    which in turns calls an empty enable() overload on Extension
%    extension instance.  Extension developers can overload
%    the enable() method in their extension for initialization actions.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/06/11 16:05:34 $

% Create and store persistent instance of extension

% Find the corresponding configuration in the database,
% if one was not passed in
if nargin<3
    hConfig = findConfig(this.ConfigDb, ...
        hRegister.Type, hRegister.Name);

    if isempty(hConfig)
        % Assertion - no good reason for it to be missing
        error('extmgr:ExtensionDb:ConfigNotFound', ...
            'Configuration for extension "%s" not found', ...
            [hRegister.Type ':' hRegister.Name]);
    end
end

% Check if configuration is enabled
if ~hConfig.Enable
    % Need to enable extension, and all that goes with it
    % (Registration, property merging, etc, via listener)
    %
    % We get here only on initial power-up, when no source
    % has been added and no configuration has been loaded
    % (i.e., all configs are disabled).

    % Enable the configuration
    % triggers recursive call to add
    hConfig.Enable = true;
end

% NOTE 1: We do not check for adding duplicate entries.
%         processAll() removes any existing instances first, for example,
%         before calling add() in a loop.
%
% NOTE 2: Sources could go in as duplicates - when a new source is
%         attempted, the old source is left enabled - until the new
%         one is confirmed to be working.  So we NEED to allow
%         duplicate entries - at least, for a short duration.
%
%         Consider a "checkForDupExtension" overload, for which Sources
%         perform one type of check, while Tools (etc) perform a
%         different (default?) check

% Instantiate extension class, using application-instance object
% Record the resulting extension-instance object
%
% Note that this will check out a license if the class resides
% in a license-protected directory.  It may fail.
%

try

    if ~hConfig.Enable
        error('extmgr:ExtensionDb:DisabledConfig', ...
            ['Configuration for extension "%s" is found to be ' ...
            'disabled after adding the instance'], ...
            [hRegister.Type ':' hRegister.Name]);
    end

    % Verify that all required extensions are added before we add this one.
    % The majority of the time 'Depends' is empty.
    for indx = 1:length(hRegister.Depends)

        if isempty(getExtension(this, hRegister.Depends{indx}))
            error('extmgr:ExtensionDb:MissingDependentExtension', ...
                'Extension "%s:%s" cannot be enabled unless "%s" is enabled.', ...
                hRegister.Type, hRegister.Name, hRegister.Depends{indx});
        end
    end

    % Merge the properties from the register to the configuration.
    mergePropDb(hRegister, hConfig, this.MessageLog);

    % Create instance
    % Could fail, e.g., by invalid user-supplied code
    % Pass application instance in case there are special tasks
    % the extension needs to do (allocate listeners, etc) during
    % instantiation (i.e., prior to an optional enable() method call)
    hExtension = feval(hRegister.class, this.Application, hRegister, hConfig);

    % Add new plug-in (Extension-derived) instance to database
    % Must put new object FIRST in arg list
    %  - wrong way to do this: connect(this,hExtension,'down')
    connect(hExtension,this,'up');

    % We want to "batch up" the installGUI calls, so each instance does not
    % incrementally update the GUI until all enabled instances are added.
    % enableExtension() takes an optional 2nd arg to suppress UI updates,
    % that is passed in varargin.  When this method is called 1 at a time,
    % we just install the GUI, but when this is called by
    % extmgr.Driver.processAll we suppress the rendering.
    enableExtension(hExtension, varargin{:});

catch e
    % Failure to instantiate extension
    %
    % Issue an error to the message log, and
    % disable the extension configuration

    % Let user know of the extension instantiation failure
    local_failExtensionMsg(this,hRegister,e);

    % EXTENSION CONSTRAINT ISSUE:
    %     Suppose this (failed) extension has a type-constraint such as
    %     "EnableOne" or "EnableAll". We should not disable this extension,
    %     because it will violate the constraint. Perhaps we should "fail
    %     out" here, and shut down the scope. For simplicity, we shut down
    %     the extension and violate the constraint, launch a failure
    %     message to the log and hopefully rely on dependency analysis to
    %     prevent "bad things" from happening.  The scope will not likely
    %     function as desired, but the scope should be "stable", and the
    %     user should be aware as to what has happened.

    notifyOfConstraintViolationIfDisabled( ...
        hRegister, hConfig, this.MessageLog);

    % Disable the extension
    hConfig.Enable = false;
end


%%
function notifyOfConstraintViolationIfDisabled(hRegister,hConfig,hMessageLog)

% Get extension type database
hRegisterDb     = hRegister.up;
hRegisterTypeDb = hRegisterDb.RegisterTypeDb;
hConstraint     = getConstraint(hRegisterTypeDb, hConfig.Type);

if hConstraint.willViolateIfDisabled(hConfig.up, hConfig)
    % Let user know of the constraint violation that will ensue
    local_violateConstraintMsg(hMessageLog,hRegister);
end

%%
function local_violateConstraintMsg(hMessageLog,hRegister)
% Add message to log, if a message log is available

if ~isempty(hMessageLog)
    summary = sprintf('Disabling "%s" violates constraint',getFullName(hRegister));
    details = coreDetailMsg(hRegister, ...
        'Disabling failed extension violates constraint');
    hMessageLog.add('Fail','Extension',summary,details);
end

%%
function local_failExtensionMsg(this,hRegister,e)
% Add message to log, if a message log is available

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('%s failed to instantiate',getFullName(hRegister));
    details = coreDetailMsg(hRegister, ...
        'Extension class failed to instantiate');
    details = [details ...
        '<b>Error message:</b><br>' uiservices.cleanErrorMessage(e) '<br><br>' ...
        '<b>Disabling extension.</b><br>'];
    hMessageLog.add('Fail','Extension',summary,details);
end

%%
function details = coreDetailMsg(hRegister,title)
% Construct common detail message content

details = sprintf([ title ':<br>' ...
    '<ul>' ...
    '<li>Type: %s' ...
    '<li>Name: %s' ...
    '<li>Class: %s' ...
    '<li>Description: %s' ...
    '<li>File: %s' ...
    '</ul>'], ...
    hRegister.Type, hRegister.Name, hRegister.Class, ...
    hRegister.Description, hRegister.File);

% [EOF]
