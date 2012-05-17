function [LP, codistr] = hEyeImpl(codistr, m, n, className)
%hEyeImpl  Implementation for TensorProductCodistributor.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:06:07 $


if ~isempty(className)
    classArg = {className};
else
    classArg = {};
end

codistr = codistr.hGetCompleteForSize([m, n]);

localLinInd = codistr.hFindDiagElementsInLocalPart();

LPsize = codistr.hLocalSize();
LP = zeros(LPsize, classArg{:});
LP(localLinInd) = 1;
