function [x,idx] = sort(x,varargin)
%Embedded MATLAB Library Function

%   Copyright 2004-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''sort'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isreal(x) || isa(x,'float'), ...
    'Complex inputs to SORT must be ''double'' or ''single''.');
if nargout == 2
    [x,idx] = eml_sort(x,varargin{:});
else
    % Although separating this case is not strictly necessary, it helps the
    % compiler eliminate the index vector idx when compiling eml_sort.
    x = eml_sort(x,varargin{:});
end