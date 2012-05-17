%REMOVE Remove key-value pairs from containers.Map
%   REMOVE(myMap, KEYS) erases all key-value pairs in Map object myMap that
%   are specified by the KEYS argument. KEYS can be a scalar key or a cell
%   array of keys.
%
%   Using REMOVE changes the count of the elements in the Map. 
%
%   Examples:
%   Remove the key-value pair with key name 'one' from myMap:
%
%       remove(myMap, 'one');  
%
%   Remove key-value pairs with key names 'one' and 'two' from myMap:
%
%       remove(myMap, ({'one', 'two'});
%
%   See Also containers.Map, values, isKey, keys, size, length

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:07 $
%   Built-in function.