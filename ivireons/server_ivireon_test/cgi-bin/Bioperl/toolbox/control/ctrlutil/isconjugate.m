function boo = isconjugate(r)
%ISCONJUGATE   Checks if roots from a complex conjugate set.

%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:44:52 $
boo = isequal(sort(r(imag(r)>0)),sort(conj(r(imag(r)<0))));