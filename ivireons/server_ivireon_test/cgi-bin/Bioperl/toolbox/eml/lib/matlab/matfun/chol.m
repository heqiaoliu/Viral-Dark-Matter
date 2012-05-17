function [A,p] = chol(A,uplo)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ...
    ['Function ''chol'' is not defined for values of class ''' class(A) '''.']);
if nargin == 2
    eml_assert(eml_is_const(uplo) && ...
        ischar(uplo) && ...
        strcmp(eml_tolower(uplo),'upper') || ...
        strcmp(eml_tolower(uplo),'lower'), ...
        'Second input must be a constant ''upper'' or ''lower''.');
    if eml_tolower(uplo(1)) == 'u'
        uplochar = 'U';
    else
        uplochar = 'L';
    end
else
    uplochar = 'U';
end
eml_assert(nargout <= 1 || ...
    (~eml_is_const(size(A,1)) && ~eml_is_const(size(A,2))), ...
    ['The input matrix must be variable-size in both dimensions ', ...
    'when nargout == 2.']);
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
eml_lib_assert(ndims(A) == 2 && m == n, ...
    'MATLAB:square', ...
    'Matrix must be square.');
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
RZERO = zeros(class(A));
if n == ZERO
    p = 0;
    return
end
if nargout <= 1
    % Check for non-real diagonal entries.
    for j = 1:n
        if imag(A(j,j)) ~= RZERO
            p = double(j);
            eml_error('MATLAB:chol:matrixMustBePosDefWithRealDiag', ...
                'Matrix must be positive definite with real diagonal.');
            return
        end
    end
end
% Perform the factorization.
[A,info] = eml_xpotrf(uplochar,n,A,ONE,n);
if info == ZERO;
    jmax = n;
else
    if nargout < 2
        eml_error('MATLAB:posdef', ...
            ['Matrix must be positive definite. \n' ...
            'For a matrix with very small eigenvalues, MATLAB and \n' ...
            'Embedded MATLAB may disagree on whether or not it is \n' ...
            'positive definite due to rounding errors.']);
    end
    jmax = eml_index_minus(info,1);
end
if uplochar == 'L'
    % Zero entries above the main diagonal.
    for j = 2:jmax
        for i = ONE:eml_index_minus(j,1)
            A(i,j) = RZERO;
        end
    end
else
    % Zero entries below the main diagonal.
    for j = 1:jmax
        for i = eml_index_plus(j,1):jmax
            A(i,j) = RZERO;
        end
    end
end
% Trim the output matrix.
if nargout == 2
    assert(jmax <= m && jmax <= n); %<HINT>
    A = A(1:jmax,1:jmax);
    p = double(info);
end
