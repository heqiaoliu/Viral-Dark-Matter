function [q,r] = deconv(b,a)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments');
eml_assert(isa(b,'float'), ...
    ['Function ''deconv'' is not defined for values of class ''' ...
    class(b) '''.']);
eml_assert(eml_is_const(isvector(b)), ...
    ['First argument must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(b), 'First argument must be a vector.');
eml_assert(isa(a,'float'), ...
    ['Function ''deconv'' is not defined for values of class ''' ...
    class(a) '''.']);
eml_assert(eml_is_const(isvector(a)), ...
    ['Second argument must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(a), 'Second argument must be a vector.');
eml_lib_assert(~isempty(a), ...
    'EmbeddedMATLAB:deconv:secondInputNotVector', ...
    'Second argument must be a non-empty vector.');
if a(1) == 0
    eml_error('MATLAB:deconv:ZeroCoef1', ...
        'First coefficient of A must be non-zero.')
end
nb = eml_numel(b);
na = eml_numel(a);
qzero = eml_scalar_eg(b,a);
r = eml.nullcopy(eml_expand(qzero,size(b)));
if na > nb
    q = qzero;
    for k = 1:nb
        r(k) = b(k);
    end
else
    % Deconvolution and polynomial division are the same operations
    % as a digital filter's impulse response B(z)/A(z):
    if ~eml_is_const(size(b,1)) || ...
            (eml_is_const(size(b,2)) && size(b,2) == 1)
        x = [1;zeros(nb-na,1)];
    else
        x = [1,zeros(1,nb-na)];
    end
    [q,zf] = filter(b,a,x);
    lq = eml_numel(q);
    for k = 1:lq
        r(k) = 0;
    end
    for k = lq+1:nb
        r(k) = a(1)*zf(k-lq);
    end
end
