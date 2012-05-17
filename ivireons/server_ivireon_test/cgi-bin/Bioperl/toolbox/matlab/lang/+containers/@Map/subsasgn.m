%SUBSASGN Subscripted assignment into containers.Map objects.
%   myMap(KEY) = V assigns the value of V into the element of myMap specified 
%   by the KEY. V must be of the same type as other values of the Map.
%
%   Example:
%       myMap = containers.Map({'a', 'b', 'c'}, ...
%                    {'Boston', 'New York', 'Natick'});
%       myMap('dE') = 'Cambridge';
%
%   Map objects do NOT support '.' or '{}' indexing.  They also do not
%   support multiple indexing, i.e. myMap(key1:keyN).
%
%   See Also containers.Map, values, keys, remove, subsref

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:14:09 $
%   Built-in function.