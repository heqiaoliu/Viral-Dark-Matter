function [V,D] = eig(A,B,opt)
%Embedded MATLAB Library Function

%   Limitations:
%
%   1. The QZ algorithm is used in all cases.  Consequently, for the
%      standard eigenvalue problem (B identity), the results often will
%      be similar to those obtained using
%
%      [V,D] = eig(A,eye(size(A)),'qz')
%
%      in MATLAB.  However, V may represent a different basis of
%      eigenvectors, and the eigenvalues in D may not be in the same order.
%
%   2. Options 'balance' and 'nobalance' are not yet supported for the
%      standard eigenvalue problem, and 'chol' is not yet supported for
%      the symmetric generalized eigenvalue problem.
%
%   3. Outputs are always of the complex type.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin < 2 || ~ischar(B), ...
    'The ''balance'' and ''nobalance'' options are not currently supported');
eml_assert(nargin < 3 || (ischar(opt) && strcmp(opt,'qz')), ...
    'Only the ''qz'' option is currently supported.');
eml_assert(isa(A,'float'), ...
    ['Function ''eig'' is not defined for values of class ''' class(A) '''.']);
if nargin < 2
    ZERO = complex(real(eml_scalar_eg(A)));
    if nargout < 2
        [info,alpha1,beta1] = eml_xgeev(A+ZERO);
        V = eml_div(alpha1,beta1);
    else
        [info,alpha1,beta1,V] = eml_xgeev(A+ZERO);
        D = diag(eml_div(alpha1,beta1));
    end
else
    ZERO = complex(real(eml_scalar_eg(A,B)));
    if nargout < 2
        [info,alpha1,beta1] = eml_xggev(A+ZERO,B+ZERO);
        V = eml_div(alpha1,beta1);
    else
        [info,alpha1,beta1,V] = eml_xggev(A+ZERO,B+ZERO);
        D = diag(eml_div(alpha1,beta1));
    end
end
if info < 0
    eml_warning('EmbeddedMATLAB:eig:QZfailed','The QZ method failed.');
elseif info > 0
    eml_warning('EmbeddedMATLAB:eig:QZnonconvergence', ...
        'QZ iteration failed to converge.');
end
