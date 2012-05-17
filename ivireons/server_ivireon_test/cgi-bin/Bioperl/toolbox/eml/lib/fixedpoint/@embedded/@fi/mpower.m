function yout = mpower(a,kin)
%Embedded MATLAB Library Function

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.4 $ $Date: 2009/12/28 04:10:56 $
eml.extrinsic('emlGetNTypeForMpower');
eml.extrinsic('strcmpi');
eml_assert(nargin == 2, 'Mpower expects 2 input arguments.');
k = int32(kin);

eml_assert(~(isfi(a)&&isslopebiasscaled(numerictype(a))),...
    ['Inputs to ''mpower'' that are FI objects must have an integer '...
    'power-of-two slope, and a bias of 0.']);
eml_lib_assert((ndims(a) == 2)&&eml_is_const(ndims(a) == 2)&&isequal(size(a,1),size(a,2)),...
    'fi:mpower:inputEither2dSquareOrScalar',...
    'Inputs to ''mpower'' must be square matrices that are 2-d, or scalar inputs')
eml_assert(isreal(k)&&isequal(k,floor(k))&&(k>=0), ['Exponent input to ''mpower''' ...
    ' must be a real-valued, non-negative integer.'])
eml_assert(eml_is_const(k), 'Exponent input to ''mpower'' must be a constant.');
if ~isfloat(a)&&~eml_is_const(size(a))
    sMode = eml_const(get(a, 'SumMode'));
    eml_lib_assert((strcmpi(sMode,'SpecifyPrecision')||strcmpi(sMode,'KeepLSB')), ...
        'fi:mpower:sumModeRestrictedForVarS', ...
        ['Embedded MATLAB only supports SumModes ''SpecifyPrecision'' and ''KeepLSB'' '...
            'for ''mpower'' when the size of the input can vary at run-time.']);
end
if isfloat(a)
    
    atemp = eml_cast(a, eml_fi_getDType(a));
    y = eml_cast(mpower(atemp, eml_cast(k,'double')), numerictype(a));
elseif isscalar(a)&&eml_is_const(isscalar(a))
    
    y = power(a, k);
elseif (k == 1)
    
    y = a;
elseif (k == 0)
    
    tEye = numerictype(false,1,0);
    y = fi(zeros(size(a)), tEye);
    for diagidx = 1:size(a,1)
        y(diagidx,diagidx) = 1;
    end
else
    
    fma = eml_fimath(a);
    pmode = eml_const(get(fma,'ProductMode'));
    smode = eml_const(get(fma,'SumMode'));

    isanymodesp = eml_const(strcmpi(pmode,'SpecifyPrecision'))||eml_const(strcmpi(smode,'SpecifyPrecision'));
    arebothmodeskmsb = eml_const(strcmpi(pmode,'KeepMSB'))&&eml_const(strcmpi(smode,'KeepMSB'));
    isanymodekmsb = eml_const(strcmpi(pmode,'KeepMSB'))||eml_const(strcmpi(smode,'KeepMSB'));

    if eml_const(isanymodesp)
        
        y = compute_mpower_typec(a, k);
    elseif eml_const(isanymodekmsb)
        
        ispmodekmsb = eml_const(strcmpi(pmode,'KeepMSB'));
        issmodeklsb = eml_const(strcmpi(smode,'KeepLSB'));
        ispmodeklsb = eml_const(strcmpi(pmode,'KeepLSB'));
        ispmodefp = eml_const(strcmpi(pmode,'FullPrecision'));
        issmodefp = eml_const(strcmpi(smode,'FullPrecision'));
        isanymodefp = eml_const(ispmodefp||issmodefp);
        awl = get(a, 'WordLength');
        swl = get(fma, 'SumWordLength');
        pwl = get(fma, 'ProductWordLength');
        if eml_const(ispmodekmsb&&issmodeklsb)
            
            n = swl - pwl;
        else
            
            if eml_const(isreal(a))
                
                nsz = eml_const(ceil(log2(size(a,1))));
            else
                
                nsz = eml_const(ceil(log2(size(a,1)+1)));
            end
            if (isanymodefp||arebothmodeskmsb)
                
                n = nsz;
            elseif ispmodeklsb
                n = (pwl - swl) - awl + nsz;
            end
        end
        y = compute_mpower_typeb(a, k, n);
    else
        y = compute_mpower_typea(a, k);
    end
    
end
yout = eml_fimathislocal(y, false);

function y = compute_mpower_typea(a, k)%#eml
[fmA, ty, szA, ega] = init_mpower(a, k);
as = stripscaling(a);
ty1 = numerictype(ty, 'fractionlength', 0);
bzero = eml_cast(ega, ty1, fmA);
b = eml.nullcopy(eml_expand(bzero, szA));
b(:) = as*as;
for idx = 3:1:k
    b(:) = b*as;
end
y = reinterpretcast(b, ty);


function y = compute_mpower_typeb(a, k, n)%#eml
[fmA, ty, szA, ega] = init_mpower(a, k);
as = stripscaling(a);
ty1 = numerictype(ty, 'fractionlength', 0);
bzero = eml_cast(ega, ty1, fmA);
b = eml.nullcopy(eml_expand(bzero, szA));
b(:) = stripscaling(as*as);
ta = numerictype(a);
ta1 = numerictype(ta,'fractionlength',ta.wordlength+n);
as1 = reinterpretcast(as,ta1);
for idx = 3:1:k
    b(:) = b*as1;
end %for
y = reinterpretcast(b, ty);

function y = compute_mpower_typec(a, k)%#eml
b1 = a*a;
if (k == 2)
    y = b1;
else
    [fmA, ty, szA, ega] = init_mpower(a, k);
    yzero = eml_cast(ega, ty, fmA);
    y = eml.nullcopy(eml_expand(yzero, szA));
    y(:) = b1;

    for pwridx = 3:1:k
        y(:) = y*a;
    end
end

function [fmA, ty, szA, ega] = init_mpower(a, k)
eml_must_inline;
eml.extrinsic('emlGetNTypeForMpower');
maxWL = eml_option('FixedPointWidthLimit');
fmA = eml_fimath(a);
if eml_is_const(size(a))

    szAc = eml_const(size(a));
else

    szAc = eml_const([2 2]);
end
szA = size(a);
ega = eml_scalar_eg(a);
ty = eml_const(emlGetNTypeForMpower(ega,szAc,k,fmA,maxWL));