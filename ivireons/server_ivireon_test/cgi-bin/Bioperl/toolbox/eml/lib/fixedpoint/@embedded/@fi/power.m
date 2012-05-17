function yout = power(a,k)
%Embedded MATLAB Library Function

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.5 $ $Date: 2009/12/28 04:10:59 $

eml.extrinsic('emlGetNTypeForPower');
eml.extrinsic('strcmpi');
eml_assert(nargin == 2, 'Power expects 2 input arguments.');

eml_assert(isnumeric(k),...
    'Exponent input to ''power'' must be of type ''numeric''.');
eml_assert(eml_is_const(k), 'Exponent input to ''power'' must be a constant.');
eml_assert(isreal(k)&&isequal(k, floor(k))&&isscalar(k)&&(k >= 0), ...
    'Exponent input to ''power'' must be a positive, real-valued integer.');

eml_assert(~(isfi(a)&&isslopebiasscaled(numerictype(a))),...
    ['Inputs to ''power'' that are FI objects must have an integer power-'...
    'of-two slope, and a bias of 0.']);

iskmsb = eml_const(strcmpi(get(a,'productmode'),'KeepMSB'));
isspecp = eml_const(strcmpi(get(a,'productmode'),'SpecifyPrecision'));
if isfloat(a)
    atemp = eml_cast(a, eml_fi_getDType(a));
    y = eml_cast(power(atemp, eml_cast(k, 'double')), numerictype(a));
elseif (k == 1)
    y = a;
elseif (k == 0)
    tOnes = numerictype(false,1,0);
    y = fi(ones(size(a)), tOnes);
elseif iskmsb
    % KeepMSB
    y = compute_power_kmsb(a, k);
elseif isspecp
    % SpecifyPrecision
    y = compute_power_specp(a, k);
else
    % FullPrecision/KeepLSB
    y = compute_power_fullprecision_klsb(a,k);
end

yout = eml_fimathislocal(y, false);


function y = compute_power_fullprecision_klsb(a, k)
% call init_power which returns the output numerictype (ty), the size of the 
% input array a (szA), and  a bucket that has appropriate complex-ness, and
% the output type if the productmode is neither FullPrecision nor KeepLSB
[ty, szA, tempzero] = init_power(a, k, true);
temp = eml.nullcopy(eml_expand(tempzero, szA));
as = stripscaling(a);
temp(:) = as.*as;
for pwridx = 3:1:k    
    temp(:) = temp.*as;
end
y = reinterpretcast(temp,ty);


function y = compute_power_kmsb(a, k)
[ty, szA, bzero] = init_power(a, k, false);
b = eml.nullcopy(eml_expand(bzero,szA));
bs = stripscaling(b);
as = stripscaling(a);
temp = as.*as;
bs(:) = stripscaling(temp);
ta = numerictype(a);
awl = eml_const(get(a,'wordlength'));
% following the first multiply, all remaining multiples have to have a
% special numerictype setting in order to pick up the Most Significant bits
% of the result. For real input this is a type with zero integer
% word-length. For complex input this is a type with -1 integer word length
if isreal(a)
    ta1 = numerictype(ta, 'fractionlength', awl);
else
    ta1 = numerictype(ta, 'fractionlength', awl+1); 
end
as1 = reinterpretcast(as, ta1);
for pwridx = 3:1:k
    bs(:) = bs.*as1;
end
y = reinterpretcast(bs, ty);


function y = compute_power_specp(a,k)
[ty, szA, bzero] = init_power(a, k, false);
b = eml.nullcopy(eml_expand(bzero,szA));
b(:) = a.*a;
for pwridx = 3:1:k
    b(:) = b.*a;
end
y = reinterpretcast(b, ty);

function [ty, szA, bzero] = init_power(a, k, tostrip)
eml_must_inline;
eml.extrinsic('emlGetNTypeForPower');
maxWL = eml_option('FixedPointWidthLimit');
fmA = eml_fimath(a);
ty = eml_const(emlGetNTypeForPower(eml_scalar_eg(a),k,fmA,maxWL));
if eml_const(tostrip)
    astrip = stripscaling(a);
    ega = eml_scalar_eg(astrip);
    ttemp = eml_const(emlGetNTypeForPower(ega,k,fmA,maxWL));
else
    ega = eml_scalar_eg(a);
    ttemp = ty;
end
szA = size(a);
bzero = eml_cast(ega,ttemp,fmA);
