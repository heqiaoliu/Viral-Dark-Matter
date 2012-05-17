function G = nested(n)
%NESTED Nested dissection ordering.
%   G = nested(n) generates a nested dissection numbering of an n-by-n grid.
%
%   See also DELSQ, NUMGRID.

%   C. Moler, 1990.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:33:09 $

% The actual numbering is done recursively by nestdiss.
G = zeros(n,n);
G(2:n-1,2:n-1) = nestdiss(zeros(n-2,n-2),0);
