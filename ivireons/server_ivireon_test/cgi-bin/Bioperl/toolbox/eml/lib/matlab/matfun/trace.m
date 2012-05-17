function t = trace(a)
%Embedded MATLAB Library Function

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(a,'numeric') || islogical(a) || ischar(a), ...
    ['Function ''trace'' is not defined for values of class ''' class(a) '''.']);
eml_lib_assert(ndims(a) == 2 && size(a,1) == size(a,2), 'MATLAB:square', ...
    'Matrix must be square.');
if isa(a,'single')
    outcls = 'single';
else
    outcls = 'double';
end
t = cast(eml_scalar_eg(a),outcls);
for k = 1:size(a,1);
    t = t + cast(a(k,k),outcls);
end
