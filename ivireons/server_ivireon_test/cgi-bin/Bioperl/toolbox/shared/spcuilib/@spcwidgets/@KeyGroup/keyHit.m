function isHit = keyHit(hGroup,keyStruct)
%KEYHIT Test for a key that has been handled by a child key binding.
%   Y = KEYHIT(G,K) tests whether the key described by key event structure
%   K is handled by a binding function supplied by one of the KeyBinding
%   children of KeyGroup G.  Returns TRUE if the current key was handled
%   by this KeyGroup.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:38:33 $

% Create/access key ID string and function-handle caches
[cachedKeys,cachedFcns] = getKeyCache(hGroup);

% Find match of key to cached list of all keys registered in group
% A registered key was hit if index is not empty
idx = find(strcmpi(keyStruct.Key,strrep(cachedKeys, ' ', '')));
isHit = ~isempty(idx);
if isHit
    % Execute registered keypress function
    feval(cachedFcns{idx},hGroup);
end

% [EOF]
