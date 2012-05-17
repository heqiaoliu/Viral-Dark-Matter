function L = mpower(sys,k)
%MPOWER  Repeated product of IDMODELS.
%   Requires Control System Toolbox.
%
%   MODm = MPOWER(MOD,K) is invoked by MOD^K where MOD is any
%   IDMODEL object with the same number of inputs and outputs,
%   and K must be an integer.  The result is the IDMODEL MODm
%   which is an IDSS object, describing
%     * if K>0, MOD * ... * MOD (K times)
%     * if K<0, INV(MOD) * ... * INV(MOD) (K times)
%     * if K=0, the static gain EYE(SIZE(MOD)).
%
%   Covariance information is lost in the transformation.
%
%   The noise inputs are first eliminated.
%
%   See also  PLUS, MTIMES.

%    Copyright 1986-2009 The MathWorks, Inc.
%    $Revision: 1.3.4.5 $  $Date: 2009/12/05 02:03:07 $

sys.CovarianceMatrix = [];
try
    sys1 = ss(sys('m'));
catch E
    throw(E)
end

try
    L = mpower(sys1,k);
    if isa(sys,'idpoly')
        L = idpoly(L);
        L = pvset(L,'BFFormat',pvget(sys,'BFFormat'));
    else
        L = idss(L);
    end
catch E
    throw(E)
end
