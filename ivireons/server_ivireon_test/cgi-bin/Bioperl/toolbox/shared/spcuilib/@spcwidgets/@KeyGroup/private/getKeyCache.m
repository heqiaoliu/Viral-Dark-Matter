function [cachedKeys, cachedFcns] = getKeyCache(hGroup)
%GETKEYCACHE Return private key caches.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:06 $

if isempty(hGroup.cachedKeys)
    updateCache(hGroup);
end
cachedKeys = hGroup.cachedKeys;
cachedFcns = hGroup.cachedFcns;
    
% [EOF]
