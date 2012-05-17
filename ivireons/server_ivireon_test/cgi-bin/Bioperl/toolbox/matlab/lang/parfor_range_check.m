function range = parfor_range_check(range)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/05/18 20:49:12 $
    
dims = size(range);
if dims(1) ~= 1 || length(dims) > 3
    if isempty(range)
        range = [1, 0];
        return
    end
    id = 'MATLAB:parfor_range_must_be_row_vector';
    txt = xlate('The range of a parfor statement must be a row vector.  See %s.');
elseif ~isnumeric(range)
    id = 'MATLAB:parfor_range_must_be_numeric';
    txt = xlate('The range of a parfor statement must be numeric.  See %s.');
else
    if isempty(range)
        range = [1 0]; % the canonical empty range
        return
    end
    a = range(1);
    b = range(end);
    if a <= b && isequal(range, a:b)
        range = [a, b];
        return
    end
    id = 'MATLAB:parfor_range_not_consecutive';
    txt = xlate('The range of a parfor statement must be increasing consecutive integers.  See %s.');
end
% At this point, there is something wrong with the range, given by id and txt.
% The full text of the error message will have link to the doc.
error(id,...
      txt,...
      doclink(...
              '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', ...
              xlate('Parallel Computing Toolbox, "parfor"')))
