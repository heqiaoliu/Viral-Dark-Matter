function A = eml_matlab_zlascl(cfrom,cto,A)
%Embedded MATLAB Private Function

%   ZLASCL multiplies the M by N complex matrix A by the real scalar
%   CTO/CFROM.  This is done without over/underflow as long as the final
%   result CTO*A(I,J)/CFROM does not over/underflow.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

FLT_RADIX = 2;
SMLNUM = eml_rdivide(FLT_RADIX * realmin(class(A)),eps(class(A)));
BIGNUM = eml_rdivide(1,SMLNUM);
cfromc = cfrom;
ctoc = cto;
notdone = true;
while notdone
    cfrom1 = cfromc * SMLNUM;
    cto1 = eml_rdivide(ctoc,BIGNUM);
    if (abs(cfrom1) > abs(ctoc)) && (ctoc ~= 0)
        mul = SMLNUM;
        notdone = true;
        cfromc = cfrom1;
    elseif abs(cto1) > abs(cfromc)
        mul = BIGNUM;
        notdone = true;
        ctoc = cto1;
    else
        mul = eml_rdivide(ctoc,cfromc);
        notdone = false;
    end
    A = mul * A;
end
