function hRegisterType = addtype(this,varargin)
%ADDTYPE Add extension type to extension type registration database.
%   ADDTYPE(hRegisterDb, type)
%     type is a string specifying the extension registration type,
%     such as 'tools', etc

% This function is all lower case because users will need to use it.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/06/11 16:05:40 $

hRegisterTypeDb = this.RegisterTypeDb;

% Create new extension type object
%
% RegisterType objects hold one extension type registration
% We don't know how many args the user passed, so we use
% varargin to capture and pass them all:

try
    hRegisterType = extmgr.RegisterType(varargin{:});
catch e
    % Error during instantiation of the extension type object
    % Don't add to database - just report error
    failRegisterMsg(this, e);
    return
end

% NOTE: We must allow a type to be added after an extension of that type,
% since "find" order is uncontrolled.

% Check for duplicate registration type
if ~isempty(hRegisterTypeDb.findType(hRegisterType.Type))
    % Duplicate extension registration type found
    % Add warning message to queue, but it's not an error

    % To create a useful error message, we include the full path
    % to the file containing the registration information.
    %
    %   register() sets up a temp "scratch" file name in
    %   this, representing the name of the current extension
    %   file being processed.  This is solely to prepare for error
    %   message reporting here:
    
    dupRegisterMsg(this,hRegisterType);
    return;
end

% Add extension type info to appropriate database
add(hRegisterTypeDb,hRegisterType);

% Debug:
successMsg(this,hRegisterType);


%%
function failRegisterMsg(this, e)

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('Failed to register type');
    details = sprintf([ 'Extension file failed to register type' ...
        '<ul>' ...
        '<li>File: %s' ...
        '</ul>'], ...
        this.FileBeingProcessed);

    details = [details ...
        '<b>Error message:</b><br>' uiservices.cleanErrorMessage(e)];
    hMessageLog.add('Fail','Extension',summary,details);
end


%%
function dupRegisterMsg(this,newRegisterType)

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('Duplicate type "%s" registered', ...
        newRegisterType.Type);
    details = coreDetailMsg(this,newRegisterType, ...
        'Duplicate extension type registered');
    details = [details ...
        '<b>Previous type registration overwritten.</b>'];
    hMessageLog.add('Warn','Extension',summary,details);
end

%%
function successMsg(this,newRegisterType)
hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = sprintf('Type "%s" registered',newRegisterType.Type);
    details = coreDetailMsg(this,newRegisterType, ...
        'Registered extension type');
    hMessageLog.add('Info','Extension',summary,details);
end

%%
function details = coreDetailMsg(this,newRegisterType,title)
% Construct common detail message content

details = sprintf([ title ...
    '<ul>' ...
    '<li>Type: %s' ...
    '<li>Constraint: %s' ...
    '<li>Order: %d' ...
    '<li>File: %s' ...
    '</ul>'], ...
    newRegisterType.Type, class(newRegisterType.Constraint), ...
    newRegisterType.Order, this.FileBeingProcessed);

% [EOF]
