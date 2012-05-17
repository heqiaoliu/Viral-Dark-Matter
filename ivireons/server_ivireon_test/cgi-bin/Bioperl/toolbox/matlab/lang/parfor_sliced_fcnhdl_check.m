function parfor_sliced_fcnhdl_check(varargin)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $   $Date: 2009/12/14 22:25:36 $

    for idx = 1:2:numel(varargin)
        if isa(varargin{idx+1}, 'function_handle')
            error('MATLAB:parfor_sliced_function_handle', ...
                  ['The sliced variable ' varargin{idx} ' must not refer to a function handle.  ' ...
                   'To invoke the function handle in the parfor loop, use "feval(' ...
                   varargin{idx} ', args)".  See %s'], ...
                  doclink('/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_FCNHDL_CHECK', ...
                          xlate('Parallel Computing Toolbox, "parfor"')))
        end
    end
end
