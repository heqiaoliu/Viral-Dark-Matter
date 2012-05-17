function tf = checkreservednames(names)
%CHECKRESERVEDNAMES Check if dataset array variable or observation names conflict with reserved names.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:04 $

reservedNames = {'VarNames' 'ObsNames' 'Properties'};
if ischar(names) % names is either a single string ...
    which = strcmp(names, reservedNames);
else             % ... or a cell array of strings
    which = false(size(reservedNames));
    for i = 1:length(names)
        which = which | strcmp(names{i}, reservedNames);
    end
end

tf = any(which);
if (nargout == 0) && tf
    which = find(which,1);
    error('stats:dataset:checkreservednames:ReservedNameConflict', ...
          'Variable names conflict with reserved variable name ''%s''.',reservedNames{which});
end

