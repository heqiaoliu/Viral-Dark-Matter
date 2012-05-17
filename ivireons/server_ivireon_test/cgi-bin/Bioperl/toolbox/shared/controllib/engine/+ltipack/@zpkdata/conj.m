function D = conj(D)
% Forms model with complex conjugate coefficients.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:22 $
for ct=1:prod(size(D.k))
    D.z{ct} = conj(D.z{ct});
    D.p{ct} = conj(D.p{ct});
end
D.k = conj(D.k);