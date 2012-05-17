function D = pElementwiseUnaryOp(F, A)
%pElementwiseUnaryOp Perform elementwise unary operations
%   D2 = codistributed.pElementwiseUnaryOp(F, D1) performs the elementwise 
%   unary operation F on all elements of D1.


%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:53 $

codistr = getCodistributor(A);
LP = getLocalPart(A);
[LP, codistr] = codistr.hElementwiseUnaryOpImpl(F,  LP);

D = codistributed.pDoBuildFromLocalPart(LP, codistr);
