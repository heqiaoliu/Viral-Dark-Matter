function enable(this)
%ENABLE Called by enableInst when extension instance is enabled.
%   Overload for UserIntfExt.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/08/14 04:07:48 $


% Cross-link the AutoOpenMode properties
% The two properties are on:
%   - the hMessageLog instance-specific object, and
%   - the hExtCfg configuration property.
%
% This will cause the scope property dialog and the message log dialog to
% be cross-linked as well, which is what we want.  (Change in one causes
% change in the other.)
%
% We can rely on the fact that this hExtCfg is linked to the hExtCfgDb
% database, etc, so ".up" is defined
hExtCfg     = this.Config;
hMessageLog = this.Application.MessageLog;
local_LinkAutoOpenMode_Properties(hExtCfg,hMessageLog);
hUIMgr = this.Application.getGUI;

h = hUIMgr.findchild('Menus','File','FileSets',...
    'Configs','CfgSetRecentFiles','CfgSetItems','ConfigPreferences');
this.RecentConfigurations = h.recentFiles;
h.recentFiles.LoadCallback = @()loadRecentConfig(this);
h.recentFiles.setMax(8);
h.recentFiles.EmptyListMsg = '<no recent configuration file>';

propertyChanged(this, 'ShowStatusbar');
propertyChanged(this, 'ShowMainToolbar');
propertyChanged(this, 'ShowPlaybackToolbar');
propertyChanged(this, 'ShowLoadConfigSet');

%%
function local_LinkAutoOpenMode_Properties(hExtCfg,hMessageLog)
% Cross-link the AutoOpenMode properties:
%   - A: hMessageLog object property
%   - B: hExtDriver configuration object property


% Find the autoopen config property
hCfgProp = findProp(hExtCfg.PropertyDb,'MessageLogAutoOpenMode');

% If the extension is disabled, or we didn't use a
% message log, we cannot link the properties
if ~isempty(hMessageLog) && ~isempty(hCfgProp)
    % Get the configuration property object (ExtProp) associated with
    % the AutoOpenMode property
    
    % Link A->B
    % Propagate changes to the AutoOpenMode popup in the instance-specific
    % message log to the related property on the extension dialog
    %
    % Add dynamic property to the message log, for easily lifecycle mgmt
    % The message log is scope-instance specific, as is the property
    % dialog, so there's no fear of multiple identical attempts to
    % create this property
    %
    % NOTE: Since the Message Log is not serialized itself, don't
    % serialize links to it from hExtCfg.
    %
    pname = 'CrossLinkedAutoOpenModeListener';
    if isempty(findprop(hMessageLog,pname))
        p = schema.prop(hMessageLog,pname,'handle.listener');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy      = 'off';
    end
    set(hMessageLog, pname, ...
        handle.listener(hMessageLog,'AutoOpenModeChanged', ...
        @(hh,ev)set(hCfgProp,'Value',hMessageLog.AutoOpenMode)));

    % Link B->A
    % Propagate changes in the AutoOpenMode property as found in the scope
    % property dialog to the corresponding popup in the Message log.
    %
    % Add same dynamic property name to the ExtCfg object
    if isempty(findprop(hExtCfg,pname))
        p = schema.prop(hExtCfg,pname,'handle.listener');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy      = 'off';
    end
    set(hExtCfg, pname, ...
        handle.listener(hCfgProp, ...
        hCfgProp.findprop('Value'), 'PropertyPostSet', ...
        @(hh,ev)set(hMessageLog,'AutoOpenMode',hCfgProp.Value)));
    
    % Finally, in case we've just enabled the ExtCfg and had only a
    % shallow config (i.e., no properties - which would only happen
    % the first time if it was disabled and never been enabled in
    % this session), yet the message log was open previously (and still
    % remains open!), we should update the message log property with the
    % (now current) config value which is the single-truth.
    %
    % Note that we don't expect UserIntfExt to be disabled, but we're
    % protecting ourselves for future possibility in a rare situation.
    %
    set(hMessageLog,'AutoOpenMode',hCfgProp.Value);
end

% [EOF]
