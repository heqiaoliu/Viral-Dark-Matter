%SIZE Size of containers.Map object
%   D = SIZE(myMap) returns the two-element row vector D = [M,1], where M
%   is the number of key-value pairs in the Map. 
%
%   [M1,M2,M3,...,MN] = SIZE(myMap) returns [M, 1, ..., 1] 
%
%   M = SIZE(myMap, DIM) returns the number of key-value pairs if DIM is 1, 
%   and otherwise returns 1.
%
%   Example:	
%       myMap = containers.Map({'a', 'b', 'c'}, {'Boston', 'New York', 'Natick'});
%       d = size(myMap)
%       d =
%           3     1
%
%   See Also containers.Map, values, isKey, keys, length

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:08 $
%   Built-in function.