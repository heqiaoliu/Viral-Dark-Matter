function valuesStruct = upgradeConfigValuesStructToCurrentVersion(valuesStruct, originalVersionNum)
; %#ok Undocumented
% Static method to upgrade a configuration structure from its original version to the 
% current version of the toolbox.  See pSetFromStruct to get a vague idea of the 
% format of the structure.

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $  $Date: 2009/12/22 18:51:30 $ 

% Keep the current version as a persistent as this function will get called once for
% every configuration that is loaded - either via the preferences or by importing a 
% configuration .mat file.  Don't bother with mlock on this file as it's pretty
% trivial to reload it after a clear.
persistent currentVersionNum
persistent currentVersionString
if isempty(currentVersionNum) || isempty(currentVersionString)
    currentVersionNum = com.mathworks.toolbox.distcomp.util.Version.VERSION_NUM;
    currentVersionString = char(com.mathworks.toolbox.distcomp.util.Version.VERSION_STRING);
end

if originalVersionNum == currentVersionNum
    % Version of the configuration matches the current, so return early.
    return;
end

originalVersionString = char(com.mathworks.toolbox.distcomp.util.Version.getVersionStringFromNumber(originalVersionNum));
if isempty(originalVersionString)
    % Couldn't determine the corresponding version string of the original version number,
    % so warn and return.  This is most likely to occur if the version number is too large 
    % i.e. we are trying to "upgrade" a newer version to an older version.
    warning('distcomp:configuration:differentVersions', ...
            ['Attempting to use version %s of Parallel Computing Toolbox ', ...
            'to load a configuration that contains an unknown version number of %d.  ', ...
            'You might be trying to load a configuration from a newer version of the ', ...
            'product.'], currentVersionString, originalVersionNum);
    return;
end

if originalVersionNum > currentVersionNum
    % Don't know how to deal with configurations from a higher version, so warn and return.
    % Very unlikely to get in here as we will probably have already failed to convert 
    % originalVersionNum into a string in the block above.
    warning('distcomp:configuration:differentVersions', ...
            ['Attempting to use version %s of Parallel Computing Toolbox ', ...
            'to load a configuration that was created with version %s of the product.'], ...
            currentVersionString, originalVersionString);
    return;
end

try
    % Perform the upgrades incrementally
    for i = originalVersionNum+1:currentVersionNum
        valuesStruct = iUpgradeStructToNextVersion(valuesStruct, i); 
    end
catch err
    ex = MException('distcomp:configuration:failedToUpgrade', ...
        'Failed to upgrade configuration from version %d to %d', ...
        originalVersionString, currentVersionString);
    ex = ex.addCause(err);
    throw(ex);
end


%---------------------------------------------------------------
% iUpgradeStructToNextVersion
%---------------------------------------------------------------
function valuesStruct = iUpgradeStructToNextVersion(valuesStruct, nextVersionNumber)
% Upgrade the value struct to the nextVersionNumber.  The assumption is that upgrades
% will be performed incrementally i.e. to upgrade from v1 to v4, we upgrade from 
% v1 to v2 to v3 to v4.

switch nextVersionNumber
    case 10 % R2009b, V4.2
        valuesStruct = iUpgradeCCSSchedulerType(valuesStruct);
    otherwise
        % No upgrading required
end


%---------------------------------------------------------------
% iUpgradeCCSSchedulerType
%---------------------------------------------------------------
function valuesStruct = iUpgradeCCSSchedulerType(valuesStruct)
% Upgrade the deprecated 'CCS' scheduler type to 'HPCSERVER'
persistent haveDisplayedMessageAboutDeprecatedCCSType

% Need to check that valuesStruct.findResource.Type is a valid
% field in the struct because the local configuration can 
% sometimes exist but have an empty values struct
if ~isfield(valuesStruct, 'findResource')
    return;
end
if ~isfield(valuesStruct.findResource, 'Type')
    return;
end

if ~strcmpi(valuesStruct.findResource.Type, 'ccs')
    return;
end

% We want to display this message about the deprecated CCS type only once
if isempty(haveDisplayedMessageAboutDeprecatedCCSType)
    haveDisplayedMessageAboutDeprecatedCCSType = true;

    fprintf(['Found a CCS scheduler configuration from a previous version \n' ...
        'of Parallel Computing Toolbox.  The CCS scheduler type will be \n' ...
        'removed in a future version.   Please use the HPCSERVER scheduler \n' ...
        'type instead.  Your existing CCS parallel configurations will be \n' ...
        'updated automatically.\n']);
end

% Change the type to hpcserver instead
valuesStruct.findResource.Type = 'hpcserver';
