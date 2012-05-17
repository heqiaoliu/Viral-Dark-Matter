function name = matchpropertyname(a,name,exact)
%MATCHPROPERTYNAME Validate a dataset array property name.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:33 $

% This matches names against this list of property names, including
% 'ObsNames'and 'VarNames', even though they are not under the 'props' field.
propertyNames = [ dataset.propsFieldNames; {'ObsNames'; 'VarNames'} ];

if ~(ischar(name) && isvector(name) && (size(name,1)==1))
    error('stats:dataset:matchpropertyname:InvalidPropertyName', ...
          'Invalid property name.');
end

if nargin < 3 || ~exact
    j = find(strncmp(name,propertyNames,length(name)));
else
    j = find(strcmp(name,propertyNames));
end
if isempty(j)
    error('stats:dataset:matchpropertyname:UnknownProperty', ...
          'Unknown dataset property: %s.', name);
elseif ~isscalar(j)
    error('stats:dataset:matchpropertyname:AmbiguousProperty', ...
          'Ambiguous dataset property name: %s.', name);
end

name = propertyNames{j};
