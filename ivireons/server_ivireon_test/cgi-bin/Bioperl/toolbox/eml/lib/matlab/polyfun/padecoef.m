function [a,b] = padecoef(T,n)
%Embedded MATLAB Library Function

%   Limitations:
%   The case T == 0 is not supported because the output in MATLAB has a 
%   different size when T == 0 and n > 0 (scalar) than when T > 0 and n > 0
%   (vector of length n+1).  Although supporting this degenerate case is
%   possible with variable sizing, it seems unlikely any user would want to
%   introduce a variable size result from a fixed size input in order to
%   support this special case.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin == 1
    n = 1;
end
eml_prefer_const(n);
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'N must be a constant.');
eml_lib_assert(isa(n,'numeric') && isscalar(n) && isreal(n) && ...
    n >= 0 && n == floor(n), ...
    'EmbeddedMATLAB:nMustBeRealPosIntScalar', ...
    'N must be a real positive integer scalar.');
eml_assert(isscalar(T), 'T must be scalar.');
eml_assert(isa(T,'float'), 'T must be a float.');
a = eml.nullcopy(eml_expand(eml_scalar_eg(T),[1,n+1]));
b = eml.nullcopy(a);
if T < 0
    eml_error('MATLAB:padecoef:NegativeTorN','T and N must be non negative.');
elseif T == 0
    eml_error('MATLAB:padecoef:TZeroNotSupported','T=0 is not supported.');
    % This case not supported because the output when T==0 (a = b = 1) has
    % a different size than when T>0 and N>0.
else
    % The coefficients of the Pade approximation are given by the
    % recursion   h[k+1] = (N-k)/(2*N-k)/(k+1) * h[k],  h[0] = 1
    % and
    %     exp(-T*s) == Sum { h[k] (-T*s)^k } / Sum { h[k] (T*s)^k }
    a(end) = 1;
    b(end) = 1;
    for k = n:-1:1
        fact = eml_div(eml_div(T*k,n+k),n-k+1);
        a(k) = (-fact) * a(k+1);
        b(k) = fact * b(k+1);
    end
    a = eml_div(a,b(1));
    b = eml_div(b,b(1));
end
