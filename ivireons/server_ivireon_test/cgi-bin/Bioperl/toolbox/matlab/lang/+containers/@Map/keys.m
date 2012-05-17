%KEYS Return keys of containers.Map object
%   K = KEYS(myMap) returns a cell array containing all of the keys stored
%   in myMap.
%
%   Examples:
%
%       myMap = containers.Map({'a', 'b', 'c'},...
%                       {'Boston', 'New York', 'Natick'});
%       keys = keys(myMap)
%       keys =   
%           'a'    'b'    'c' 
%
%   See Also containers.Map, values, isKey, remove
%

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:05 $
%   Built-in function.