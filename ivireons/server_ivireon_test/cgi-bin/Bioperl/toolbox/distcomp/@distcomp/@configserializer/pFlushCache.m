function pFlushCache(obj)
; %#ok Undocumented
%Maintain configuration invariants and write the cache to disk.  

%   Copyright 2007-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:58:13 $ 

persistent currentVersionNumber

if isempty(currentVersionNumber)
    currentVersionNumber = com.mathworks.toolbox.distcomp.util.Version.VERSION_NUM;
end

obj.pMaintainCacheInvariants();

% NB configurations are stored in the preferences as a structure with the following fields:
%   configurations      an array of structs
%   current             the name of the current default configuration
%   versionNumber       the version number in which the preferences were saved (this 
%                       will usually be the current version, except when MATLAB 
%                       has just been upgraded.
if obj.FlushCache
    % Commit to disk.
    setpref(obj.Group, ...
        {'configurations', 'current', 'versionNumber'}, ...
        {obj.Cache.configurations, obj.Cache.current, currentVersionNumber});
    obj.CacheCounter = obj.CacheCounter + 1;
end

