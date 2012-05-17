function c = lcm(a,b)
%Embedded MATLAB Library Function

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml 

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(a,'float'), ['Function ''lcm'' is not defined for values of class ''' class(a) '''.']);
eml_assert(isa(b,'float'), ['Function ''lcm'' is not defined for values of class ''' class(b) '''.']);
eml_assert(isreal(a) && isreal(b), 'Inputs must be real.');
if notPosInts(a) || notPosInts(b)
    eml_error('MATLAB:lcm:InputNotPosInt',...
        'Input arguments must contain positive integers.');
end
c = gcd(a,b); 
for k = 1:eml_numel(c)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    c(k) = ak.*eml_rdivide(bk,c(k));
end

%--------------------------------------------------------------------------

function p = notPosInts(a)
p = false;
for k = 1:eml_numel(a)
    if floor(a(k)) ~= a(k) || a(k) < 1
        p = true;
        break
    end
end

%--------------------------------------------------------------------------
