function y = power(a,b)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

% Adapted from utComplexScalarPower in src\util\libm\cmath1.cpp
eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(isa(a,'numeric'), ...
    ['Function ''power'' is not defined for values of class ''' class(a) '''.']);
eml_assert(isa(b,'numeric'), ...
    ['Function ''power'' is not defined for values of class ''' class(b) '''.']);
if isinteger(a) || isinteger(b)
    eml_assert(isreal(a) && isreal(b), ...
        'Complex integer arithmetic is not supported.');
    eml_assert(isa(a,class(b)) || ...
        (isscalar(a) && isa(a,'double')) || ...
        (isscalar(b) && isa(b,'double')), ...
        'Integers can only be combined with integers of the same class, or scalar doubles.');
    if strcmp(eml.target(),'hdl')
        y = intpower_hdl(a,b);
    else
        y = intpower(a,b);
    end
else
    y = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b);
    for k = 1:eml_numel(y)
        ak = eml_scalexp_subsref(a,k);
        bk = eml_scalexp_subsref(b,k);
        if isreal(y)
            if ak < 0 && eml_scalar_floor(bk) ~= bk
                eml_error('EmbeddedMATLAB:power:domainError', ...
                    'Domain error. To compute complex results, make at least one input complex, e.g. ''power(complex(a),b)''.');
            end
            % if isnan(ak) || isnan(bk) % some compilers: pow(nan,0) --> 1.
            %     y(k) = ak + bk;
            % else
                y(k) = eml_pow(ak,bk);
            % end
        else
            y(k) = scalar_complex_power(ak,bk,class(y));
        end
    end
end

%--------------------------------------------------------------------------

function y = scalar_complex_power(a,b,cls)
eml_must_inline;
ar = real(a);
ai = imag(a);
br = real(b);
bi = imag(b);
if (ai == 0) && (bi == 0) && (ar >= 0) % real result.
    y  = cast(complex(eml_pow(ar,br)),cls);
elseif (bi == 0.0) && isfinite(br) && (eml_scalar_floor(br) == br) % complex^integer
    t2 = a;
    y = complex(ones(cls));
    e = eml_scalar_abs(br);
    while e > 0
        ed2 = eml_scalar_floor(eml_rdivide(e,2));
        if 2*ed2 ~= e
            y = t2 * y;
        end
        t2 = t2 * t2;
        e = ed2;
    end
    if br < 0
        y = eml_div(ones(cls),y);
    end
else
    if isreal(a)
        t = b*eml_scalar_log(complex(a));
    else
        t = b*eml_scalar_log(a);
    end
    tr = eml_exp(real(t));
    ti = imag(t);
    y  = cast(complex(tr*eml_scalar_cos(ti),tr*eml_scalar_sin(ti)),cls);
end

%--------------------------------------------------------------------------

function y = intpower(a,b)
% Integer power function.
eml_must_inline;
y = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b);
eml_assert(isa(a,class(b)) || ...
    (isinteger(a) && isscalar(b) && isa(b,'double')) || ...
    (isinteger(b) && isscalar(a) && isa(a,'double')), ...
    'Integers can only be combined with integers of the same class, or scalar doubles.');
ucls = eml_unsigned_class(class(y));
uone = ones(ucls);
for k = 1:eml_numel(y)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    eml_lib_assert(bk >= 0 && eml_scalar_floor(bk) == bk, ...
        'MATLAB:integerPower', ...
        'Integers can only be raised to positive integral powers.');
    y(k) = 1;
    bku = cast(bk,ucls);
    aklz = ak < 0;
    while true
        if eml_bitand(bku,uone)
            y(k) = ak * y(k);
        end
        bku = eml_rshift(bku,uone);
        if bku == 0
            break
        end
        ak = ak * ak;
    end
    if ~isinteger(bk) && bk > intmax(ucls) && aklz
        % sign(y(k)) could be wrong because bku saturated.
        if bk == 2*eml_scalar_floor(eml_rdivide(bk,2))
            y(k) = -y(k);
        end
    end
end

%--------------------------------------------------------------------------

function y = intpower_hdl(a,b)
% Integer power function using structured code for HDL.
eml_must_inline;
y = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b);
eml_assert(eml_is_integer_class(class(a)) && isa(a,class(b)), ...
    'For HDL target both inputs must belong to the same integer class.');
if eml_isa_uint(y)
    nbitsm1 = eml_const(eml_int_nbits(class(y)) - 1);
else
    nbitsm1 = eml_const(eml_int_nbits(class(y)) - 2);
end
nbitcls = 'int8';
zerobits = zeros(nbitcls);
for k = 1:eml_numel(y)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    if bk < zeros(class(bk))
        eml_error('MATLAB:integerPower', ...
            'Integers can only be raised to positive integral powers.');
    else
        if eml_bitslice(bk,0,0) ~= 0
            y(k) = ak;
        else
            y(k) = 1;
        end
        % Count the number of bits on, not including the first bit.  
        % The first bit has already been processed.
        nbitson = zerobits; 
        for j = 1:nbitsm1
            if eml_bitslice(bk,j,j) ~= 0
                nbitson = eml_plus(nbitson,1,nbitcls,'wrap');
            end
        end
        for j = 1:nbitsm1
            if nbitson > zerobits
                ak = ak * ak;
                if eml_bitslice(bk,j,j) ~= 0
                    y(k) = ak * y(k);
                    nbitson = eml_minus(nbitson,1,nbitcls,'wrap');
                end
            end
        end
    end
end

%--------------------------------------------------------------------------
