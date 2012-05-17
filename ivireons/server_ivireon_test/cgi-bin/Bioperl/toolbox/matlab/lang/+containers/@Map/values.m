%VALUES Return values of containers.Map object
%
%   V = VALUES(myMap, KEYS) returns a cell array of values V that correspond
%   to the specified KEYS in myMap. The KEYS argument is optional.
%   If not specified, it defaults to all keys in the Map.
%
%   Examples:
%   Return all values in Map object myMap:
%
%       myMap = containers.Map({'a', 'b', 'c'}, ...
%                   {'Boston', 'New York', 'Natick'});
%       vals = values(myMap)
%       vals = 
%           'Boston'    'New York'   'Natick'
%
% 	Return those values in Map object myMap that correspond to the keys
% 	specified in the input cell array:
%	
%       vals = values(myMap, {'b', 'c'}) 
%       vals = 
%           'New York'   'Natick'
%
%   See Also containers.Map, keys, isKey
%

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:11 $
%   Built-in function.