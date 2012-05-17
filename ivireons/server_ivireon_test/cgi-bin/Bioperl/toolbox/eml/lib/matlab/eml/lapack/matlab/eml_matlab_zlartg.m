function [cs,sn,r] = eml_matlab_zlartg(f,g)
%Embedded MATLAB Private Function

%   ZLARTG generates a plane rotation so that
%   [  CS  SN  ]     [ F ]     [ R ]
%   [  __      ]  .  [   ]  =  [   ]   where CS**2 + |SN|**2 = 1.
%   [ -SN  CS  ]     [ G ]     [ 0 ]

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

FLT_RADIX = 2;
LNBT2 =  2*eml_log(FLT_RADIX);
SAFMIN = eml_rdivide(FLT_RADIX * realmin(class(f)),eps(class(f)));
% SAFMN2 = DLAMCH('B')**INT(LOG(SAFMIN/EPS)/LOG(DLAMCH('B'))/TWO)
SAFMN2 = FLT_RADIX^fix(eml_rdivide(eml_log(eml_rdivide(SAFMIN,eps(class(f)))),LNBT2));
SAFMX2 = eml_rdivide(1,SAFMN2);
ONE = ones(eml_index_class);
scale = max2(absinf(f),absinf(g));
fs = f;
gs = g;
count = zeros(eml_index_class);
rescaledir = 0;
if scale >= SAFMX2
    while true
        count = eml_index_plus(count,ONE);
        fs = fs * SAFMN2;
        gs = gs * SAFMN2;
        scale = scale * SAFMN2;
        if scale < SAFMX2
            break
        end
    end
    rescaledir = 1;
elseif scale <= SAFMN2
    if g == 0
        cs = ones(class(f));
        sn = complex(zeros(class(f)));
        r = f;
        return
    end
    while true
        count = eml_index_plus(count,ONE);
        fs = fs * SAFMX2;
        gs = gs * SAFMX2;
        scale = scale * SAFMX2;
        if scale > SAFMN2
            break
        end
    end
    rescaledir = -1;
end
f2 = abssq(fs);
g2 = abssq(gs);
if f2 <= max2(g2,1)*SAFMIN
    if f == 0
        cs = zeros(class(f));
        r = eml_dlapy2(real(g),imag(g));
        d = eml_dlapy2(real(gs),imag(gs));
        % Do complex/real division explicitly with two real divisions
        sn = complex(eml_rdivide(real(gs),d),eml_rdivide(-imag(gs),d));
        return
    end
    f2s = eml_dlapy2(real(fs),imag(fs));
    % G2 and G2S are accurate
    % G2 is at least SAFMIN,and G2S is at least SAFMN2
    g2s = sqrt(g2);
    % Error in CS from underflow in F2S is at most
    % UNFL / SAFMN2 .lt. sqrt(UNFL*EPS) .lt. EPS
    % If MAX(G2,ONE)=G2,then F2 .lt. G2*SAFMIN,
    % and so CS .lt. sqrt(SAFMIN)
    % If MAX(G2,ONE)=ONE,then F2 .lt. SAFMIN
    % and so CS .lt. sqrt(SAFMIN)/SAFMN2 = sqrt(EPS)
    % Therefore,CS = F2S/G2S / sqrt(1 + (F2S/G2S)**2) = F2S/G2S
    cs = eml_rdivide(f2s,g2s);
    % Make sure abs(FF) = 1
    % Do complex/real division explicitly with 2 real divisions
    if absinf(f) > 1
        d = eml_dlapy2(real(f),imag(f));
        ff = complex(eml_rdivide(real(f),d),eml_rdivide(imag(f),d));
    else
        dr = SAFMX2*real(f);
        di = SAFMX2*imag(f);
        d = eml_dlapy2(dr,di);
        ff = complex(eml_rdivide(dr,d),eml_rdivide(di,d));
    end
    sn = ff*complex(eml_rdivide(real(gs),g2s),eml_rdivide(-imag(gs),g2s));
    r = cs*f + sn*g;
else
    % This is the most common case.
    % Neither f2 nor f2/g2 are less than SAFMIN
    % f2s cannot overflow,and it is accurate
    f2s = sqrt(1 + eml_rdivide(g2,f2));
    % do the f2s(real)*fs(complex) multiply with two real multiplies
    r = complex(f2s*real(fs),f2s*imag(fs));
    cs = eml_rdivide(1,f2s);
    d = f2 + g2;
    % do complex/real division explicitly with two real divisions
    sn = complex(eml_rdivide(real(r),d),eml_rdivide(imag(r),d));
    sn = sn*conj(gs);
    if rescaledir > 0
        for i = ONE : count
            r = r*SAFMX2;
        end
    elseif rescaledir < 0
        for i = ONE : count
            r = r*SAFMN2;
        end
    end
end

%--------------------------------------------------------------------------

function x = max2(x,y)
eml_must_inline;
% Simple maximum of 2 elements.  Output class is class(x).
if y > x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------

function y = absinf(ff)
eml_must_inline;
y = max2(abs(real(ff)),abs(imag(ff)));

%--------------------------------------------------------------------------

function y = abssq(ff)
eml_must_inline;
y = real(ff)*real(ff) + imag(ff)*imag(ff);

%--------------------------------------------------------------------------
