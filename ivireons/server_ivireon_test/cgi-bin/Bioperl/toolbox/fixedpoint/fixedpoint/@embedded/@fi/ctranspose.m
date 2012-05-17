%CTRANSPOSE Complex conjugate transpose of fi object
%   C = CTRANSPOSE(A) returns the complex conujgate transpose of fi object
%   A in fi object C. It is also called for the syntax A'.
%   
%   Example: Result of CTRANSPOSE compared with result of TRANSPOSE:
%     p = fi([2+j 2-3*j]);
%     q = ctranspose(p)
%     r = transpose(p)
%     % q and r contain the fi objects corresponding to complex conjugate
%     % transpose and transpose of p, respectively
%
%   See also EMBEDDED.FI/TRANSPOSE  

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/19 21:18:24 $