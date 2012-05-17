function endpoint = parfor_endpoint_check(endpoint)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.4.5 $   $Date: 2009/12/22 18:54:04 $

% NOTE: the scalar test being done first ensures that all other tests
% return a scalar logical - the isfinite and integerness tests can produce
% vector outputs if endpoint is a vector.
if ~isscalar(endpoint) || ~isnumeric(endpoint) || ~isreal(endpoint) ...
   || ~isfinite(endpoint) || endpoint ~= round(endpoint)
    error('MATLAB:parfor_range_endpoint',...
          'The endpoint of a parfor range must be an integer.  See %s', ...
           doclink(...
                   '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', ...
                   xlate('Parallel Computing Toolbox, "parfor"')))
end
