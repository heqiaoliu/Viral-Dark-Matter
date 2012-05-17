function newRegister = add(this,varargin)
%ADD Add instance-specific extension instance database.
%   ADD(hRegisterDb, <args for Register object>)
%
%   Just as a brief reminder of what those args are,
%      ADD(hRegisterDb, Type, Name)
%      ADD(hRegisterDb, Type, Name, Class, Description)
%
%   Required for add (and for underlying Register constructor call):
%     Type is the extension registration type, such as 'sources','tools', etc
%       This argument is required; others are optionally passed to the
%       constructor if present
%     Name is a string name for the plug-in suitable as a brief identifier
%       in the preferences GUI dialog
%
%   Optional args:
%     Class is a string defining the class constructor, usually of the
%       form "package.class".
%     Description is a longer string describing the functionality of the
%       plug-in, generally 10-15 words in length.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/07/23 18:44:10 $

% Create new extension definition
%
% Register objects hold one extension registration
% We don't know how many args the user passed, including whether
% they passed the "required" args (Type and Name) - so we use
% varargin to capture and pass them all:

try
    newRegister = extmgr.Register(varargin{:});
catch e
    % Error during instantiation of the extension data
    % Don't add to database - just report error
    failRegisterMsg(this, e);
    return
end

% % Check for duplicate registration type/name
if ~isempty(this.findRegister(newRegister.Type,newRegister.Name))
    % Duplicate extension registration found
    %   (or, at least a type/name conflict was identified)
    % Add error message to queue and exit

    % To create a useful error message, we include the full path
    % to the file containing the registration information.
    %
    %   register() sets up a temp "scratch" file name in
    %   this, representing the name of the current extension
    %   file being processed.  This is solely to prepare for error
    %   message reporting here:

    dupRegisterMsg(this,newRegister);
    return
end

% Add registration info for new extension to database
% (object being added must be first arg, object already in tree second)
connect(newRegister,this,'up');

appDataCache = get(this, 'CachedApplicationData');
if ~isempty(appDataCache)

    % Fix up the type and name of the register using genvarname to get a
    % valid field name.
    fixedType = genvarname(newRegister.Type);
    fixedName = genvarname(newRegister.Name);

    % If there's a field in the application data cache for this register's
    % type and name add it to this register.
    if isfield(appDataCache, fixedType) && ...
            isfield(appDataCache.(fixedType), fixedName)

        regAppData = appDataCache.(fixedType).(fixedName);

        % Add all the application data to the register.
        fn = fieldnames(regAppData);
        for indx = 1:length(fn)
            newRegister.setAppData(fn{indx}, regAppData.(fn{indx}));
        end

        % Clean up the application data cache by removing fields already
        % assigned to this register and resave.
        appDataCache.(fixedType) = rmfield(appDataCache.(fixedType), fixedName);
        if isempty(fieldnames(appDataCache.(fixedType)))
            appDataCache = rmfield(appDataCache, fixedType);
        end
        if isempty(fieldnames(appDataCache))
            appDataCache = [];
        end
        set(this, 'CachedApplicationData', appDataCache);
    end
end

% Successfully registered extension
%
% Note that we add the "success" message in RegisterDb::register(),
% and not here.  that's because the add() method might be called
% with only a partial amount of information (say, just the type and
% name), yet we want all the properties to be available when we
% record the success message (e.g., only set after initial add()
% call, via h.Description=blah, etc).
%
%successRegisterMsg(this,newRegister);

% -------------------------------------------------------------------------
function failRegisterMsg(this, e)

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = 'Registration failed';
    details = ['Extension file failed to register' ...
        '<b>Error message:</b><br>' uiservices.cleanErrorMessage(e)];
    hMessageLog.add('Fail','Extension',summary,details);
end

% -------------------------------------------------------------------------
function dupRegisterMsg(this,newRegister)

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('%s failed to register',getFullName(newRegister));
    details = coreDetailMsg(this,newRegister, ...
        'Extension with duplicate type/name found');
    details = [details ...
        '<b>Extensions with duplicate type/name cannot be registered.</b>'];
    hMessageLog.add('Fail','Extension',summary,details);
end

% Unused xxx
%{
function successRegisterMsg(this,newRegister)

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('%s registered',newRegister.Name);
    details = coreDetailMsg(this,newRegister, ...
        'Extension successfully registered');
    hMessageLog.add('Info','Extension',summary,details);
end
%}

% -------------------------------------------------------------------------
function details = coreDetailMsg(this,newRegister,title)
% Construct common detail message content

details = sprintf([ title ...
    '<ul>' ...
    '<li>Type: %s' ...
    '<li>Name: %s' ...
    '<li>Class: %s' ...
    '<li>Description: %s' ...
    '<li>File: %s' ...
    '</ul>'], ...
    newRegister.Type, newRegister.Name, newRegister.Class, ...
    newRegister.Description, ...
    this.FileBeingProcessed);

% [EOF]
