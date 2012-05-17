function z = eml_div(x,y)
%Embedded MATLAB Private Function

%   Floating point and integer division: z = x./y;

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isinteger(x) || isinteger(y)
    z = eml_idiv(x,y);
else
    z = eml_fldiv(x,y);
end

%--------------------------------------------------------------------------

function z = eml_fldiv(x,y)
% Floating point division.
eml_must_inline;
if isreal(x) && isreal(y)
    z = eml_rdivide(x,y);
else
    z = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
    for k = 1:eml_numel(z)
        xk = eml_scalexp_subsref(x,k);
        yk = eml_scalexp_subsref(y,k);
        ar = real(xk);
        ai = imag(xk);
        br = real(yk);
        bi = imag(yk);
        brm = abs(br);
        bim = abs(bi);
        % The following may appear to be too much effort to avoid unnecessary
        % arithmetic, but the "extra" cases were introduced to match MATLAB
        % in a./b, where [a,b] = meshgrid([1 1i 1+1i nan nan*1i nan+nan*1i
        % inf inf*1i inf+inf*1i]);
        if bi == 0
            if ai == 0
                z(k) = eml_rdivide(ar,br);
            else
                if ar == 0
                    z(k) = complex(0,eml_rdivide(ai,br));
                else
                    z(k) = complex(eml_rdivide(ar,br),eml_rdivide(ai,br));
                end
            end
        elseif br == 0
            if ar == 0
                z(k) = eml_rdivide(ai,bi);
            elseif ai == 0
                z(k) = complex(0,eml_rdivide(-ar,bi));
            else
                z(k) = complex(eml_rdivide(ai,bi),eml_rdivide(-ar,bi));
            end
        elseif brm > bim
            s = eml_rdivide(bi,br);
            d = br + s*bi;
            z(k) = complex(eml_rdivide(ar+s*ai,d),eml_rdivide(ai-s*ar,d));
        elseif brm == bim
            brs = 0.5;
            if br < 0
                brs = -0.5;
            end
            bis = 0.5;
            if bi < 0
                bis = -0.5;
            end
            z(k) = complex(eml_rdivide(ar*brs+ai*bis,brm), eml_rdivide(ai*brs-ar*bis,brm));
        else
            s = eml_rdivide(br,bi);
            d = bi + s*br;
            z(k) = complex(eml_rdivide(s*ar+ai,d),eml_rdivide(s*ai-ar,d));
        end
    end
end

%--------------------------------------------------------------------------

function z = eml_idiv(x,y)
% Integer division.
eml_must_inline;
eml_assert(isreal(x) && isreal(y), 'Complex integer arithmetic is not supported.');
eml_assert(isa(x,class(y)) || ...
    (isinteger(x) && (isscalar(y) && isa(y,'double'))) || ...
    (isinteger(y) && (isscalar(x) && isa(x,'double'))), ...
    'Integers can only be combined with integers of the same class, or scalar doubles.');
if isa(x,'float') || isa(y,'float')
    z = eml_mixed_integer_rdivide(x,y);
    return
end
z = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
for k = 1:eml_numel(z)
    xk = eml_scalexp_subsref(x,k);
    yk = eml_scalexp_subsref(y,k);
    if yk == 0
        if xk == 0
            z(k) = 0;
        elseif xk < 0
            z(k) = intmin(class(z));
        else
            z(k) = intmax(class(z));
        end
    elseif yk == 1
        % If tempted to remove this case, make sure that the correct
        % result is generated if xk == intmin and yk == 1.
        z(k) = xk;
    else
        q = eml_scalar_uint_rdivide(magu(xk),magu(yk));
        if (xk < 0) ~= (yk < 0)
            z(k) = eml_uminus(cast(q,class(z)));
        else
            z(k) = q;
        end
    end
end

%--------------------------------------------------------------------------

function z = eml_mixed_integer_rdivide(x,y)
% Mixed integer and scalar double division.
eml_must_inline;
z = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
for k = 1:eml_numel(z)
    xk = double(eml_scalexp_subsref(x,k));
    yk = double(eml_scalexp_subsref(y,k));
    zk = eml_rdivide(xk,yk);
    z(k) = zk;
end

%--------------------------------------------------------------------------

function y = magu(x)
% A magnitude preserving cast to the unsigned class of the same size as x.
eml_must_inline;
ucls = eml_unsigned_class(eml_index_class);
if x >= 0
    y = cast(x,ucls);
elseif x == intmin(class(x))
    y = eml_plus(intmax(class(x)),1,ucls,'wrap');
else
    y = cast(eml_uminus(x),ucls);
end

%--------------------------------------------------------------------------

function z = eml_scalar_uint_rdivide(x,y)
% Scalar unsigned integer division x/y for y~=0.
% unsigned int q = x / y;
% x -= q*y;
% if (x && (x >= ((y >> 1u) + (y & 1u)))) return q + 1u;
% return q;
eml_must_inline;
one = ones(class(x));
q = eml_rdivide(x,y,class(x),'wrap','to zero');
x = eml_minus(x,eml_times(q,y,class(x),'wrap'),class(x),'wrap');
if x > 0 && x >= eml_plus(eml_rshift(y,one),eml_bitand(y,one),class(x),'wrap')
    z = eml_plus(q,one,class(x),'wrap');
else
    z = q;
end

%--------------------------------------------------------------------------
