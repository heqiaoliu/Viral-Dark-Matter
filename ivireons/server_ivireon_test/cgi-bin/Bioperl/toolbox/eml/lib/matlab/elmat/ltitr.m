function y = ltitr(a,b,u,x0)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 3, 'Not enough input arguments.');
check_class(a);
check_class(b);
check_class(u);
eml_lib_assert(ndims(a) == 2 && ndims(b) == 2 && ndims(u) == 2, ...
    'EmbeddedMATLAB:ltitr:inputsMustBe2D', ...
    'Input arguments must be 2-D.');
am = cast(size(a,1),eml_index_class);
n = cast(size(a,2),eml_index_class);
eml_lib_assert(am == n, 'MATLAB:square', 'Matrix must be square.');
bm = cast(size(b,1),eml_index_class);
bn = cast(size(b,2),eml_index_class);
um = cast(size(u,1),eml_index_class);
un = cast(size(u,2),eml_index_class);
eml_lib_assert(n == bm && bn == un, ...
    'MATLAB:dimagree', ...
    'Matrix dimensions must agree.');
abu0 = eml_scalar_eg(a,b,u);
ONE = ones(eml_index_class);
if nargin < 4
    y = eml_expand(abu0,[um,n]);
    if isempty(u)
        return
    end
else
    check_class(x0);
    eml_lib_assert(isvector(x0) && eml_numel(x0) == n, ...
        'MATLAB:ltitr:invalidInitialCondition', ...
        'Initial condition vector has incorrect dimensions.');
    y = eml_expand(eml_scalar_eg(abu0,x0),[um,n]);
    for k = ONE:n
        y(1,k) = x0(k);
    end
end
CZERO = eml_scalar_eg(y);
CONE = CZERO + 1;
for i = ONE:eml_index_minus(um,ONE)
    ip1 = eml_index_plus(i,ONE);
    y = eml_xgemv('N',am, n,1,a,ONE,am,y,i,um,CZERO,y,ip1,um);
    y = eml_xgemv('N',bm,bn,1,b,ONE,bm,u,i,um,CONE,y,ip1,um);
end

%--------------------------------------------------------------------------

function check_class(x)
% Note that the algorithm above would work with single as well, but MATLAB 
% requires double, so we require double.
eml_assert(isa(x,'double'), ...
    ['Function ''ltitr'' is not defined for values of class ''' class(x) '''.']);

%--------------------------------------------------------------------------
