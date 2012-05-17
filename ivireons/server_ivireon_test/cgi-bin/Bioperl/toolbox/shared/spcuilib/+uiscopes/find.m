function inst = find(idx)
%FIND     Find Scope GUI instances.
%   FIND returns a vector of uiscopes.Framework objects corresponding to
%   each open instance of the scope GUI.  Order of instances is the order
%   in which the GUI's were most recently in focus; the first entry
%   corresponds to the spcified scope instance that most recently had focus,
%   etc.
%
%   FIND(I) returns only the objects corresponding to the specified
%   instance numbers I.  If I is empty, all specified scope instances are
%   returned.
%
%   FIND(0) returns the Framework object corresponding to the instance
%   of Scope that has the current window focus.  If no instance of Scope
%   currently has focus, an empty matrix is returned.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:53:43 $

if nargin<1, idx=[]; end
shh='ShowHiddenHandles';
shhState = get(0,shh);
set(0,shh,'on');
inst = getInstances(getOpenMPlayers,idx);
set(0,shh,shhState);

% -------------------------------------------------------------------------
function h = getOpenMPlayers
% Return MPlayer objects for all open MPlay GUI's

h=[];  % in case no players are open

% Find all MPlay figures
allMPlayFigs = findobj('type','figure','tag','spcui_scope_framework');

% Retrieve MPlayer objects from figures
for i=1:numel(allMPlayFigs)
    % Get mplayer object
    m = get(allMPlayFigs(i),'UserData');
    if i==1, h=m; else h(i)=m; end %#ok
end

% -------------------------------------------------------------------------
function y = getInstances(allObj,userIdx)
% Return objects corresponding to instance numbers in userIdx.
% Special handling of userIdx:
%   empty: return all instances
%   0: return instance with "current window focus",
%      or empty is no instance has focus
%   vector: return those instances, in user-specified order
%      0 cannot be in this list; an error will result

if isempty(userIdx)
    % Return all instances
    y = allObj;
    return
end

if isnumeric(userIdx)
    y = getInstancesNumeric(allObj, userIdx);
else
    y = getInstancesConfig(allObj, userIdx);
end

% -------------------------------------------------------------------------
function y = getInstancesNumeric(allObj, userIdx)

if userIdx == 0
    % Return instance with current focus
    y = [];  % setup for failure
    
    % Are there *any* figures open?
    figFocus = get(0,'CurrentFigure');
    if isempty(figFocus), return; end
    
    % See if any MPlay has same figure handle
    % Get all figure numbers from objects
    for i=1:numel(allObj)
        if figFocus == allObj(i).Parent
            y = allObj(i);  % found mplay gui with current focus
            break
        end
    end
    return
end

% Return specified instances of MPlay
%
% Get all instance numbers from objects
for i=1:numel(allObj)
    allInst(i) = allObj(i).InstanceNumber; %#ok
end
% Match them up to requested instance numbers
for i=1:numel(userIdx)
    j = find(userIdx(i) == allInst);
    if isempty(j)
        error(generatemsgid('InvalidIndex'),...
            'Specified instance index not found');
    end
    iFind(i) = j; %#ok
end
y = allObj(iFind);

% -------------------------------------------------------------------------
function y = getInstancesConfig(allObj, hScopeCfg)

targetName = class(hScopeCfg);

f = @(h) strcmp(class(h.ScopeCfg), targetName);

y = allObj.find('-function', f, '-depth', 0);

% [EOF]
