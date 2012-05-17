function y = mtimes(a,b)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(isa(a,'numeric') || islogical(a) || ischar(a), ...
    ['Function ''mtimes'' is not defined for values of class ''' ...
    class(a) '''.']);
eml_assert(isa(b,'numeric') || islogical(b) || ischar(b), ...
    ['Function ''mtimes'' is not defined for values of class ''' ...
    class(b) '''.']);
if isinteger(a) || isinteger(b)
    eml_assert(isa(a,class(b)) || ...
        (isscalar(a) && isa(a,'double')) || ...
        (isscalar(b) && isa(b,'double')), ... % 'MATLAB:mixedClasses'
        ['Integers can only be combined with integers of the same ', ...
        'class, or scalar doubles.']);
    eml_assert(isscalar(a) || isscalar(b), ... % 'MATLAB:oneOperandMustBeScalar'
        ['Integer data types are not fully supported for this ', ...
        'operation. At least one operand must be a scalar.']);
    eml_assert(isreal(a) && isreal(b), ... % 'MATLAB:complexInts'
        'Complex integer arithmetic is not supported.');
elseif (eml_is_const(isscalar(a)) && isscalar(a)) || ...
        (eml_is_const(isscalar(b)) && isscalar(b))
    % The scalar case, no dimension matching is needed.
else
    ndimOk = ndims(a) <= 2 && ndims(b) <= 2;
    innerDimOk = size(a,2) == size(b,1);
    
    if ~ndimOk || ~innerDimOk
        if isscalar(a) || isscalar(b)
            eml_lib_assert(ndimOk && innerDimOk, ...
                'EmbeddedMATLAB:mtimes:noDynamicScalarExpansion', ...
                ['Inner dimensions must agree.  Embedded MATLAB ', ...
                'generated code for a general matrix multiplication ', ...
                'at this call site.  If this should have been a ', ...
                'scalar times a variable-size matrix, the scalar ', ...
                'input must be fixed-size.']);
        else
            eml_lib_assert(ndimOk, ...
                'MATLAB:mtimes:inputsMustBe2D', ...
                'Input arguments must be 2-D.');
            eml_lib_assert(innerDimOk, ...
                'MATLAB:innerdim', ...
                'Inner matrix dimensions must agree.');
        end
    end
end
if eml_is_constant_folding || ...
        eml_ambiguous_types || ...
        strcmp(eml.target(),'hdl') || ...
        size(a,2) == 1 || size(b,1) == 1 || ...
        ~isa(a,'float') || ~isa(a,class(b)) || ...
        isreal(a) ~= isreal(b) || ...
        eml_ndims(a) > 2 || eml_ndims(b) > 2
    eml_must_inline;
    if ~isa(a,class(b))
        % This optimization is required to get integer-only code with HDL
        % for the case of integer-valued scalar double * integer array.
        if eml_is_const(isscalar(a)) && isscalar(a)
            eml_prefer_const(a);
        end
        if eml_is_const(isscalar(b)) && isscalar(b)
            eml_prefer_const(b);
        end
    end
    y = eml_mtimes(a,b);
    return
end
ONE = ones(eml_index_class);
k = cast(size(a,2),eml_index_class);
y = eml.nullcopy(eml_expand(eml_scalar_eg(a,b),[size(a,1),size(b,2)]));
if eml_is_const(isempty(y)) && isempty(y)
elseif eml_is_const(isscalar(y)) && isscalar(y)
    y = eml_xdotu(k,a,ONE,ONE,b,ONE,ONE);
else
    m = cast(size(a,1),eml_index_class);
    n = cast(size(b,2),eml_index_class);
    yZERO = eml_scalar_eg(a,b);
    y(:) = 0; % g467063
    y = eml_xgemm('N','N',m,n,k,1+yZERO,a,ONE,m,b,ONE,k,yZERO,y,ONE,m);
end
