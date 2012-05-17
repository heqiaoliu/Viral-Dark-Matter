function [acodes,bcodes] = ordinalcheck(a,b)
%ORDINALCHECK Utility for logical comparison of ordinal arrays.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:58 $

if ischar(a) % && isa(b,'ordinal')
    if size(a,1) > 1 || (ndims(a) > 2)
        error('stats:ordinal:ordinalcheck:InvalidComparison', ...
              'Cannot compare ordinal array to multiple strings.');
    end
    acodes = find(strcmp(a,b.labels));
    if isempty(acodes)
        error('stats:ordinal:ordinalcheck:LevelNotPresent', ...
              'Ordinal level %s not present.',a);
    end
    bcodes = b.codes;
elseif ischar(b) % && isa(a,'ordinal')
    acodes = a.codes;
    if size(b,1) > 1 || (ndims(b) > 2)
        error('stats:ordinal:ordinalcheck:InvalidComparison', ...
              'Cannot compare ordinal array to multiple strings.');
    end
    bcodes = find(strcmp(b,a.labels));
    if isempty(bcodes)
        error('stats:ordinal:ordinalcheck:LevelNotPresent', ...
              'Ordinal level %s not present.',b);
    end
elseif isa(a,'ordinal') && isa(b,'ordinal')
    if ~isequal(a.labels,b.labels)
        error('stats:ordinal:ordinalcheck:InvalidComparison', ...
              'Ordinal levels and their ordering must be identical.');
    end
    acodes = a.codes;
    bcodes = b.codes;
else
    error('stats:ordinal:ordinalcheck:InvalidComparison', ...
          'Invalid types for comparison.');
end
