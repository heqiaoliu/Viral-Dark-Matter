function mergePropDb(this, hConfig, hMessageLog)
%MERGEPROPDB Merge property database to a config.
%   mergePropDb(hRegister,hConfig) merges
%   the property configurations in Config with a baseline of properties
%   copied from Register, storing result back into Config.
%
%   Returns FALSE if not successful.  Caller should check type-constraint
%   violations in the case of failure, and perhaps disable the
%   appropriate extension configuration.

% Update configuration with "merged" set of properties
%
% NOTE: We cannot continue merging properties if an error occurred above
% This is a fatal error that leaves us without defined properties for
% the extension - with no registered properties, we cannot tell if the
% configuration properties are valid - like prop names and values.
% Update configuration with "merged" set of properties, so that config
% has a full set of all properties required for this extension.
%
% We do this because the loaded config set may only describe a partial
% set of properties.  For example, a stored config set from an earlier
% release may not describe all proprties in an enhanced version of an
% extension in a newer release.  Thus, we need the "baseline" properties
% from the latest registration info, then we overlay those defaults with
% any properties from the loaded set.  We also look for invalid properties,
% obsolete properties, etc.

% Merge properties from registration info and configuration info:
%  - get copy of Register PropDb as baseline
%  - get Config PropDb to add to baseline one-by-one
%  - review each Config prop to verify correctness

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/18 02:13:45 $

if nargin < 3
    hMessageLog = [];
end

% Make a deep-copy of the properties database in Register
% as a starting point for the new, merged property database
%
% This defines all possible properties for this extension,
% including current and obsolete properties.
%
defPropDb = getPropertyDb(this);

% Merge each property in hConfig property database
conPropDb = hConfig.PropertyDb;
iterator.visitImmediateChildren(defPropDb, ...
    @(regProp) local_mergeOneCfgProp(conPropDb, regProp, hMessageLog, this));

% --------------------------------------------------------------------------
function local_mergeOneCfgProp(hPropertyDb, regProp, hMessageLog, hRegister)
% Overwrite newProp value into hPropertyDb
% Check:
%   - that regProp (coming from Register) is found in hPropertyDb
%   - whether registered property in hPropertyDb is marked as obsolete
% Then overwrite hPropertyDb value with newProp

cfgProp = findProp(hPropertyDb, regProp.Name);

if isempty(cfgProp)

    try

        newProp = copy(regProp);
        newProp.Status = 'Active';

        hPropertyDb.add(newProp);

    catch e %#ok<NASGU>
        recordPropertyError(hMessageLog, hRegister, newProp);
    end
else
    
    cfgType = get(findprop(cfgProp, 'Value'), 'DataType');
    
    % These datatypes can get out of sync when the datatype is meant to be
    % an enumeration, but the cfg file was loaded before the enumeration
    % could be defined.  The load for the property, not being able to find
    % the enumeration, assigns a datatype of string.  We can fix that here.
    if strcmp(cfgType, 'string') && ~strcmp(cfgType, get(findprop(regProp, 'Value'), 'DataType'))
        
        % If the datatypes do not match, use the type from the default
        % "register" property, but the value from the configuration.
        try
            newProp = copy(regProp);
            newProp.Status = 'Active';
            newProp.Value = cfgProp.Value;
            hPropertyDb.remove(cfgProp);
            hPropertyDb.add(newProp);
        catch e %#ok<NASGU>
            recordPropertyError(hMessageLog, hRegister, newProp);
        end
    end
end

% --------------------------------------------------------------------------
function recordPropertyError(hMessageLog, hRegister, newProp)

% Value incompatible with property
if ~isempty(hMessageLog)
    summary = 'Incompatible extension property value.';
    stdInfo = sprintf([...
        '<ul>' ...
        '<li>Extension Type: %s' ...
        '<li>Extension Name: %s' ...
        '<li>Property Name: %s' ...
        '</ul>' ], ...
        hRegister.Type, hRegister.Name, ...
        newProp.Name);
    details = sprintf(['%s<br>' ...
        '%s' ...
        '<b>Ignoring this property value.</b><br>'], ...
        summary, stdInfo);
    hMessageLog.add('Warn','Configuration',summary,details);
end

% [EOF]
