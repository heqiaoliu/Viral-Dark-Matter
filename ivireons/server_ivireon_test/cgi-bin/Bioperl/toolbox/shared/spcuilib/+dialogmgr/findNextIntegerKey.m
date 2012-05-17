function nextKey = findNextIntegerKey(keyList,lowestKey,ascendingOrder)
%Return integer key based on existing key list.
%  findNextIntegerKey(keyList,lowestKey) returns an integer key to use
%  as a new entry in the keyList.  keyList is a vector of integer keys
%  that should not be use as new key values.  lowestKey is the first key
%  value that can be assigned, regardless of keys specified in keyList,
%  followed by lowestKey+1, lowestKey+2, etc.  If omitted, lowestKey is
%  assumed to be 1.  Values not appearing in keyList are returned as new
%  key values, with priority given to lowest valued keys.
%
% findNextIntegerKey(keyList,lowestKey,ascendingOrder) indicates that
% keyList is sorted in ascending order if ascendingOrder=true, increasing
% performance of key generation.  By default, ascendingOrder is assumed to
% be false.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:15 $
    
if nargin<2
    lowestKey = 1;
end

if isempty(keyList)
    % no keys - hand out lowestKey
    nextKey = lowestKey;
    return
end

if nargin<3 || ~ascendingOrder
    keyList = sort(keyList);
end

% Pre-pend sentinel key, lowestKey-1, to list
% This is lower than the first index in use (1)
% It will help us detect non-use of lowestKey, and simplify detection of
% missing keys in keyList.
keysToDiff = [lowestKey-1 keyList];

% Detect unused sequential keys in keyList
gapIdx = find(diff(keysToDiff)>1);
if isempty(gapIdx)
    % no gaps - hand out next key in sequence
    nextKey = 1+max(keysToDiff);
    return
end

% Hole in key sequence is present - choose key to fill first hole found.
% The first index in gapIdx points to the index AFTER a gap.
% We add one to the value found at the PREVIOUS index.
%
% NOTE: If a gap is found, we can guarantee at least TWO entries
nextKey = 1 + keysToDiff(gapIdx(1));
    
end
