%ISKEY Determine whether containers.Map contains key
%
%   TF = ISKEY(OBJ, KEYS) looks for the specified KEYS in the Map instance
%   OBJ, and returns logical 1 (TRUE) for those elements that it finds, and
%   logical 0 (FALSE) for those it does not. KEYS is a scalar key or cell
%   array of keys. If KEYS is nonscalar, then return value TF is a
%   nonscalar logical array that has the same dimensions and size as KEYS.
%
%   Examples: 
%   Check myMap and verify that it contains the key 'a':
%
%       myMap = containers.Map({'a', 'b', 'c'}, {'Boston', 'New York', ...
%           'Natick'}); 
%       hasKey = isKey(myMap, 'a'); 
%       hasKey = 
%    		1
%
%   Check the same Map for two keys: 'a' and 'z'. The value
%   returned in hasKeys is a two-element array that shows that the first
%   key has been found and the second has not:
%
%       hasKeys = isKey(myMap, {'a', 'z'})
%       hasKeys = 
%     		[ 1 0 ]
%
%   See Also containers.Map, values, keys, remove

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:04 $
%   Built-in function.