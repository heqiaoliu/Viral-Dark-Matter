function D = conj(D)
% Forms model with complex conjugate coefficients.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:27 $
for ct=1:prod(size(D.num))
   D.num{ct} = conj(D.num{ct});
   D.den{ct} = conj(D.den{ct});
end