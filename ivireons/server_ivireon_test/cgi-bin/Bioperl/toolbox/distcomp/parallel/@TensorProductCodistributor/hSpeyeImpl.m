function [LP, codistr] = hSpeyeImpl(codistr, m, n)
%hSpeyeImpl  Implementation for TensorProductCodistributor.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:06:08 $

codistr = codistr.hGetCompleteForSize([m, n]);

localLinInd = codistr.hFindDiagElementsInLocalPart();

LPsize = codistr.hLocalSize();
LP = spalloc(LPsize(1), LPsize(2), length(localLinInd));
LP(localLinInd) = 1;
