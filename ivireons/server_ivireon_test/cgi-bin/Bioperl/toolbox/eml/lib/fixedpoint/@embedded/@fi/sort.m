function [y,idx] = sort(x,varargin)
% Fixed-Point Embedded MATLAB Library Function

%   Copyright 2004-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.4 $  $Date: 2009/03/30 23:30:15 $

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
eml_assert(isfi(x) && ...
    (nargin < 2 || ~isfi(varargin{1})) && ...
    (nargin < 3 || ~isfi(varargin{2})), ...
    'DIM and MODE argument to SORT cannot be FI objects.');
eml_assert(isreal(x), 'Input array to be sorted must be real.');
if nargout == 2
    [x1,idx] = eml_sort(x,varargin{:});
    y = eml_fimathislocal(x1,eml_fimathislocal(x));
else
    % Although separating this case is not strictly necessary, it helps the
    % compiler eliminate the index vector idx when compiling eml_sort.
    y = eml_fimathislocal(eml_sort(x,varargin{:}),eml_fimathislocal(x));
end
