function D = conj(D)
% Forms model with complex conjugate coefficients.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:46 $
D.a = conj(D.a);
D.b = conj(D.b);
D.c = conj(D.c);
D.d = conj(D.d);
D.e = conj(D.e);